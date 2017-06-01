module ListingProcessor
  class << self
    def enqueue(account_listings_list)
      account_listings_list.select { |al| al.pending? && al.time_to_publish? && !!al.price }.group_by { |al|
        { :account => al.account, :status => al.status.to_sym }
      }.each do |group, account_listings|
        case group[:status]
          when :pending_create
            ListingProcessor.delay_for(5.seconds).create_listings(group[:account].id, account_listings.map(&:id))
          when :pending_update
            ListingProcessor.delay_for(5.seconds).update_listings(group[:account].id, account_listings.map(&:id))
          when :pending_delete
            ListingProcessor.delay_for(5.seconds).delete_listings(group[:account].id, account_listings.map(&:id))
        end
      end
    end

    def create_listings(account_id, account_listing_ids)
      account = Account.find(account_id)
      account_listings = account_listing_ids.map { |i| AccountListing.find(i) }

      account_listings.select! { |account_listing|
        account_listing.account == account &&
            account_listing.reload.status.to_sym == :pending_create
      }

      account_listings.each { |account_listing|
        account_listing.status!(:processing)
      }

      item_details = account_listings.map { |account_listing|
        map_data_fields(account_listing, :create)
      }

      puts item_details
      account.integration.add_items(item_details).each { |result|
        account_listing = account_listings.find { |al| al.id.to_i == result[:id].to_i }
        raise 'Account listing from result not found in original data set' unless account_listing
        if result[:status] == :success
          account_listing.update_columns(:uid => result[:item_id], :url => result[:url])
          account_listing.status!(:active)
        else
          account_listing.status!(:create_failed, result[:errors])
        end
      }
    rescue Exception => ex
      account_listings.each { |account_listing|
        account_listing.status!(:create_failed, ["General error"], nil, [ex.message])
      }
    end

    def update_listings(account_id, account_listing_ids)
      account = Account.find(account_id)
      account_listings = account_listing_ids.map { |i| AccountListing.find(i) }

      account_listings.select! { |account_listing|
        account_listing.account == account &&
            account_listing.reload.status.to_sym == :pending_update
      }

      account_listings.each { |account_listing|
        account_listing.status!(:processing)
      }

      item_details = account_listings.map { |account_listing|
        map_data_fields(account_listing, :update)
      }

      puts item_details
      account.integration.update_items(item_details).each { |result|
        account_listing = account_listings.find { |al| al.id.to_i == result[:id].to_i }
        raise 'Account listing from result not found in original data set' unless account_listing
        if result[:status] == :success
          account_listing.update_columns(:uid => result[:item_id], :url => result[:url])
          account_listing.status!(:active)
        else
          account_listing.status!(:update_failed, result[:errors])
        end
      }
    rescue Exception => ex
      account_listings.each { |account_listing|
        account_listing.status!(:update_failed, ["General error"], nil, [ex.message])
      }
    end

    def delete_listings(account_id, account_listing_ids)
      account = Account.find(account_id)
      account_listings = account_listing_ids.map { |i| AccountListing.find(i) }

      account_listings.select! { |account_listing|
        account_listing.account == account &&
            account_listing.reload.status.to_sym == :pending_delete
      }

      account_listings.each { |account_listing|
        account_listing.status!(:processing)
      }

      item_details = account_listings.map { |account_listing|
        {
            :id => account_listing.id,
            :item_id => account_listing.uid,
            :state => account_listing.integration_state
        }
      }
      account.integration.delete_items(item_details).each { |result|
        account_listing = account_listings.find { |al| al.id.to_i == result[:id].to_i }
        raise 'Account listing from result not found in original data set' unless account_listing
        if result[:status] == :success
          account_listing.update_columns(:uid => nil, :url => nil)
          account_listing.status!(:inactive)
        else
          account_listing.status!(:delete_failed, result[:errors])
        end
      }
    rescue Exception => ex
      account_listings.each { |account_listing|
        account_listing.status!(:delete_failed, ["General error"], nil, [ex.message])
      }
    end

    private

    def map_data_fields(account_listing, operation)
      account, listing = account_listing.account, account_listing.listing

      marketplace_category = listing.item_category.marketplace_category_mapping_for(account.marketplace).marketplace_category rescue nil
      raise "Category mapping not found" if marketplace_category.blank?

      mapped_data_fields = Hash[listing.item_category.custom_fields.map { |f| f.custom_field_mapping_for(account.marketplace) }.compact.map { |custom_field_mapping|
        custom_field = custom_field_mapping.custom_field
        marketplace_field = custom_field_mapping.marketplace_field
        # if :for specified for marketplace field config, ensure we only include this field for appropriate operation
        next if custom_field_mapping.marketplace_field_config[:for] && !custom_field_mapping.marketplace_field_config[:for].map(&:to_s).include?(operation.to_s)
        case custom_field.name
          when 'Price'
            value = account_listing.price
          when 'Discount Price'
            next if account_listing.discount_price.blank?
            value = account_listing.discount_price
          when 'Shipping Price'
            value = listing.shipping_preset.price
          when 'Quantity'
            value = [listing.quantity, 1].max
          else
            # find value in listing data fields
            data_field = listing.data_fields.find { |f| f.custom_field == custom_field && (f.marketplace.blank? || f.marketplace == account_listing.account.marketplace) } rescue nil
            custom_field_mapping.required? ? raise("Data field not found for #{custom_field.name}") : next unless data_field.try(:value)
            value = data_field.value
        end
        [marketplace_field, value]
      }.compact]

      {
          :id => account_listing.id,
          :item_id => account_listing.uid,
          :category_id => marketplace_category,
          :images => listing.images.map { |img|
            Rails.application.routes.url_helpers.root_url + img.image.url(:standard)
          },
          :data_fields => mapped_data_fields.with_indifferent_access,
          :state => account_listing.integration_state
      }
    end
  end
end
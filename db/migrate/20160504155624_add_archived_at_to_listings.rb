class AddArchivedAtToListings < ActiveRecord::Migration
  def change
    add_column :listings, :archived_at, :datetime
  end
end

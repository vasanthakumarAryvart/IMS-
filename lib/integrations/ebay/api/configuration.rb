module Integrations
  module Ebay
    module Api
      module Configuration

        def app_id
          if Rails.env.development? || Rails.env.staging?
            'Clarabyt-Inventor-SBX-5e80278ab-967998fe'
          else
            'Clarabyt-Inventor-PRD-9e805b337-5c5615e6'
          end
        end

        def dev_id
          if Rails.env.development? || Rails.env.staging?
            '4a5ce0d5-a6c8-4cf4-b43e-8712e9a25559'
          else
            '4a5ce0d5-a6c8-4cf4-b43e-8712e9a25559'
          end
        end

        def cert_id
          if Rails.env.development? || Rails.env.staging?
            'SBX-e80278ab2ed0-f804-4c86-a2da-6032'
          else
            'PRD-e805b33700fe-f9c0-4a1b-b5f1-2bd9'
          end
        end

        def ru_name
          if Rails.env.development? || Rails.env.staging?
            'Clarabyte-Clarabyt-Invent-skffdfgrz'
          else
            'Clarabyte-Clarabyt-Invent-rfzby'
          end
        end

      end
    end
  end
end

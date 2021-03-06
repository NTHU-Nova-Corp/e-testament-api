# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to get a specific property
      class GetProperty
        def self.call(requester:, property_data:)
          policy = Policies::Property.new(requester:, testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account.executor_id)

          unless policy.can_view?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to view property requested.'
          end

          property_data
        end
      end
    end
  end
end

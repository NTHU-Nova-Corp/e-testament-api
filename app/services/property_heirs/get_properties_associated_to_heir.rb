# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get property list for a heir
      class GetPropertiesAssociatedToHeir
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: nil,
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_view_properties_associated_to_heir?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # return
          PropertyHeir.where(heir_id: heir_data[:id]).all
        end
      end
    end
  end
end

# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get property list for a heir
      class GetHeirsAssociatedToProperty
        def self.call(requester:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: nil,
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_view_heirs_associated_to_property?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # return
          PropertyHeir.where(property_id: property_data[:id]).all
        end
      end
    end
  end
end

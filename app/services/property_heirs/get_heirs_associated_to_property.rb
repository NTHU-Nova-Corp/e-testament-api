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
          unless policy.can_view_properties_associated_to_heir?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # return
          property_heirs = PropertyHeir.where(heir_id: property_data[:id]).all
          properties = property_heirs.map(&:property)

          raise Exceptions::NotFoundError if properties.nil?

          properties.to_json
        end
      end
    end
  end
end

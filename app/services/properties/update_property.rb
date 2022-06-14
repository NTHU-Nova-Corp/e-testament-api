# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      # Note: Not sure if it should update info from the account object? search account > get property > update
      class UpdateProperty
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, property_data:, updated_data:)
          policy = Policies::Property.new(requester:, testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account.executor_id)
          unless policy.can_update?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to updated property selected.'
          end

          account = Account.first(id: property_data.account_id)
          unless account.properties.count do |property|
                   property.name == updated_data['name'] && property.id != property_data.id
                 end.zero?
            raise Exceptions::BadRequestError,
                  'There is already a property with the same name'
          end

          raise Exceptions::BadRequestError updated_data.keys.to_s unless property_data.update(updated_data)
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

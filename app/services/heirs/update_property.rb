# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class AssociatePropertyHeir
        def self.call(requester:, heir_data:, property_data:, new_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_account: heir_data.account,
                                              property_owner_account: property_data.account)
          unless policy.can_create_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # execute
          result = PropertyHeir.new(heir_id: heir_data[:id], property_id: property_data[:id],
                                    percentage: new_data['percentage'])
          raise Exceptions::BadRequestError, 'Could not associate the property with the heir' unless result.save

          result
        end
      end
    end
  end
end

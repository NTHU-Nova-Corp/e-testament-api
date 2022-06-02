# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class AssociatePropertyHeir
        # rubocop:disable Metrics/MethodLength
        def self.call(requester:, heir_data:, property_data:, new_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_create_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # execute
          result = PropertyHeir.new(heir_id: heir_data[:id], property_id: property_data[:id],
                                    percentage: new_data['percentage'])
          raise Exceptions::BadRequestError, 'Could not associate the property with the heir' unless result.save

          result
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end

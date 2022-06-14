# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class DeleteProperty
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, property_data:)
          policy = Policies::Property.new(requester:, testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account.executor_id)

          unless policy.can_delete?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to remove the property selected.'
          end

          unless PropertyHeir.where(property_id: property_data[:id]).count.zero?
            raise Exceptions::BadRequestError, 'Could not delete property, there are heirs associated'
          end

          unless Property.where(id: property_data[:id]).delete
            raise Exceptions::BadRequestError,
                  'Could not delete property'
          end
          true
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

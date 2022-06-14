# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class DeleteAssociationBetweenPropertyAndHeir
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, heir_data:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              testament_status: heir_data.account[:testament_status],
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: property_data.account[:executor_account_id],
                                              property_owner_executor_id: heir_data.account[:executor_account_id])
          unless policy.can_delete_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to access that project'
          end

          # execute
          unless PropertyHeir.where(property_id: property_data[:id]).delete
            raise('Could not disassociate heir from property')
          end

          true
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

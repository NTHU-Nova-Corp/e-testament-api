# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  module Services
    module Heirs
      # Create heir for account
      class DeleteHeir
        # rubocop:disable Metrics/AbcSize
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::Heir.new(requester:,
                                      testament_status: heir_data.account.testament_status,
                                      heir_owner_id: heir_data.account.id,
                                      heir_owner_executor_id: heir_data.account.executor_id)

          raise Exceptions::ForbiddenError, 'You are not allowed to remove the heir selected.' unless policy.can_delete?

          # execute
          unless PropertyHeir.where(heir_id: heir_data[:id]).count.zero?
            raise Exceptions::BadRequestError, 'Could not delete heir, there are properties associated'
          end
          raise Exceptions::BadRequestError, 'Could not delete heir' unless Heir.where(id: heir_data[:id]).delete
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end

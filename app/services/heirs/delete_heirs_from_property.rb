# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  module Services
    module Heirs
      # Create heir for account
      class DeleteHeirsFromProperty
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::Heir.new(requester:, heir_owner_account: heir_data.account)
          raise Exceptions::ForbiddenError, 'You are not allowed to remove the heir' unless policy.can_remove?

          # execute
          raise('Could not delete heir') unless PropertyHeir.where(heir_id: heir_data[:id]).delete
          raise('Could not delete heir') unless Heir.where(id: heir_data[:id]).delete
        end
      end
    end
  end
end

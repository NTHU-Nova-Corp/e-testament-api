# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to accept request for being an executor
      # TODO: Handle error
      class AcceptTestatorRequest
        def self.call(owner_account_id:, executor_account_id:)
          pending = PendingExecutorAccount.first(owner_account_id:, executor_account_id:)
          raise 'Testator not found' if pending.nil?

          testator = Account.first(id: pending.owner_account_id)
          raise 'Owner not found' if testator.nil?

          testator.update(executor_id: executor_account_id)
          pending.delete
        end
      end
    end
  end
end

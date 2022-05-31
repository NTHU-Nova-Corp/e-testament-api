# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to reject request for being an executor
      # TODO: Handle error
      class RejectTestorRequest
        def self.call(owner_account_id:, executor_account_id:)
          pending = PendingExecutorAccount.first(owner_account_id:,
                                                 executor_account_id:)
          raise 'Testor not found' if pending.nil?

          testor = Account.first(id: pending.owner_account_id)
          raise 'Owner not found' if testor.nil?

          pending.delete
        end
      end
    end
  end
end

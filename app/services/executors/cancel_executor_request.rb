# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to create request to assigned executor email
      # TODO: Handle error
      class CancelExecutorRequest
        def self.call(owner_account_id:, executor_email:)
          record = PendingExecutorAccount.where(owner_account_id:, executor_email:).first

          raise Exceptions::NotFoundError, 'Executor not found' if record.nil?

          record.delete
        end
      end
    end
  end
end

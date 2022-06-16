# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to create request to assigned executor email
      # TODO: Handle error
      class CancelExecutorRequest
        def self.call(account:, executor_email:)
          owner_full_name = "#{account['first_name']} #{account['last_name']}"

          record = PendingExecutorAccount.where(owner_account_id: account['id'], executor_email:).first

          raise Exceptions::NotFoundError, 'Executor not found' if record.nil?

          record.delete

          Services::Executors::SendCancelRequest.new(executor_email, owner_full_name).call
        end
      end
    end
  end
end

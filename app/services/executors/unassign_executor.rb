# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to create request to assigned executor email
      # TODO: Handle error
      class UnassignExecutor
        def self.call(account_id:, executor_email:)
          account = Account.first(id: account_id)
          executor = Account.first(id: account[:executor_id], email: executor_email)

          raise Exceptions::NotFoundError, 'Executor not found' if executor.nil?

          account.update(executor_id: nil)

          account_full_name = "#{account[:first_name]} #{account[:last_name]}"
          Services::Executors::SendUnassignExecutor.new(executor[:email], account_full_name).call
        end
      end
    end
  end
end

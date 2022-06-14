# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to get pending request for being an executor
      class GetSentExecutor
        def self.call(id:)
          sent_executor = Account.first(id:).executor_request_sent.first
          sent_executor_account = sent_executor.executor_account

          sent_executor_account.nil? ? sent_executor : sent_executor_account
        end
      end
    end
  end
end

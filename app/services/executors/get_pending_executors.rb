# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to get pending request for being an executor
      # TODO: Handle error
      class GetPendingExecutor
        def self.call(id:)
          Account.first(id:).executor_request_sent.first.executor_account
        end
      end
    end
  end
end

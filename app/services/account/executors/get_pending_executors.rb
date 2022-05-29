# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get pending request for being an executor
      # TODO: Handle error
      class GetExecutorPending
        def self.call(id:)
          Account.first(id:).executors_pending
        end
      end
    end
  end
end




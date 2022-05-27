# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      # TODO: Handle error
      class GetExecutorAccount
        def self.call(id:)
          executor_account = Account.first(id:).executor

          raise 'Not executor associated yet' if executor_account.nil?

          executor_account.to_json
        end
      end
    end
  end
end




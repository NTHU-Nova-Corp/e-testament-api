# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      # TODO: Handle error
      class GetExecutor
        def self.call(id:)
          executor_account = Account.first(id:).executor

          raise Exceptions::NotFoundError, 'Not found associated executor' if executor_account.nil?

          executor_account
        end
      end
    end
  end
end

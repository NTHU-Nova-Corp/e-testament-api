# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to create new account
      class CreateAccount
        def self.call(new_data:)
          raise Exceptions::BadRequestError, 'Username exists' unless Account.first(username: new_data[:username]).nil?
          raise Exceptions::BadRequestError, 'Email exists' unless Account.first(email: new_data[:email]).nil?

          new_account = Account.new(new_data)
          raise Exceptions::BadRequestError, 'Could not save account' unless new_account.save

          pending = PendingExecutorAccount.where(executor_email: new_account.email).first
          pending&.update(executor_account_id: new_account.id)
          # pending.update(executor_account_id: new_account.id)

          new_account
        end
      end
    end
  end
end

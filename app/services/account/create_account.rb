# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to create new account
      class CreateAccount
        def self.call(new_data:)
          raise 'Username exists' unless Account.first(username: new_data['username']).nil?

          new_account = Account.new(new_data)
          raise 'Could not save account' unless new_account.save

          PendingExecutorAccount.where(executor_email: new_account.email).update(executor_account_id: new_account.id)

          new_account
        end
      end
    end
  end
end

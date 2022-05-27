# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      # TODO: Handle error
      class CreateExecutorRequest
        def self.call(executor_data:)
          executor_pending = PendingExecutorAccount.new(executor_email: executor_data['email'])
          executor_pending.owner_account_id = @auth_account['id']
          executor_account = Account.first(email: executor_data['email'])
          PendingExecutorAccount.where(owner_account_id: @auth_account['id']).delete

          if executor_account.nil?
            Services::Accounts::VerifyRegistration.new({
                                                         verification_url: executor_data['verification_url'],
                                                         username: executor_data['email'],
                                                         email: executor_data['email']
                                                       }).call
          else
            executor_pending.executor_account_id = executor_account.id
          end

          executor_pending.save
        end
      end
    end
  end
end




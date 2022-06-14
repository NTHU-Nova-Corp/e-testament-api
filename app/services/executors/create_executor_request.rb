# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to create request to assigned executor email
      # TODO: Handle error
      class CreateExecutorRequest
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(account:, executor_data:)
          raise 'cannot assign account as an executor' if executor_data['email'].eql?(account['email'])

          PendingExecutorAccount.where(owner_account_id: account['id']).delete
          executor_account = Account.first(email: executor_data['email'])

          if executor_account.nil?
            Services::Accounts::VerifyRegistration.new({
                                                         verification_url: executor_data['verification_url'],
                                                         username: executor_data['email'],
                                                         email: executor_data['email']
                                                       }).call

            PendingExecutorAccount.create(owner_account_id: account['id'],
                                          executor_email: executor_data['email'])
          else
            executor_pending = PendingExecutorAccount.new(owner_account_id: account['id'],
                                                          executor_email: executor_data['email'])
            executor_pending[:executor_account_id] = executor_account.id
            executor_pending.save
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

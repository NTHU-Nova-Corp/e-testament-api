# frozen_string_literal: true

module ETestament
  module Services
    module Executors
      # Service object to create request to assigned executor email
      # TODO: Handle error
      class CreateExecutorRequest
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(account:, executor_data:)
          # verify
          if executor_data['email'].eql?(account['email'])
            raise Exceptions::BadRequestError, 'cannot assign account as an executor'
          end

          # clear
          PendingExecutorAccount.where(owner_account_id: account['id']).delete

          # prepare
          executor_account = Account.first(email: executor_data['email'])
          owner_full_name = "#{account['first_name']} #{account['last_name']}"
          executor_email = executor_data['email']

          # check
          if executor_account.nil?
            # create
            PendingExecutorAccount.create(owner_account_id: account['id'],
                                          executor_email:)
            # send email
            Services::Executors::SendRegisInvitation.new(executor_data['registration_form'], owner_full_name).call
          else
            # create
            executor_pending = PendingExecutorAccount.new(owner_account_id: account['id'],
                                                          executor_email:)
            executor_pending[:executor_account_id] = executor_account.id
            executor_pending.save

            # send email
            Services::Executors::SendInvitation.new(executor_email, owner_full_name).call
          end
        end

        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

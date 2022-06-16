# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class RejectTestatorRequest
        def self.call(owner_account_id:, executor_account_id:)
          # verify testator info
          pending = PendingExecutorAccount.first(owner_account_id:,
                                                 executor_account_id:)
          raise 'Testator not found' if pending.nil?

          testator = Account.first(id: pending.owner_account_id)
          raise 'Owner not found' if testator.nil?

          # clear pending info
          pending.delete

          # setup for sending email
          executor = Account.first(id: executor_account_id)
          testator_email = testator[:email]
          executor_full_name = "#{executor[:first_name]} #{executor[:last_name]}"

          # send email
          Services::Testators::SendRejectTestatorRequest.new(testator_email, executor_full_name).call
        end
      end
    end
  end
end

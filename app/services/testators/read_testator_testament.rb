# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class ReadTestatorTestament
        def self.call(requester:, testator_id:)
          current_account = Account.first(id: testator_id)

          raise Exceptions::BadRequestError, 'No testator found' if current_account.nil?

          if current_account.heirs.count(&:key_submitted?) < current_account.min_amount_heirs
            raise Exceptions::BadRequestError, 'There are not enough keys to release the testament'
          end

          # Update the status of the testament to Read
          Services::Accounts::Testament::Read.call(requester:, account_id: testator_id)
        end
      end
    end
  end
end

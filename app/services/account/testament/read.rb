# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      module Testament
        # Service object to get the Account Information
        class Read
          # rubocop:disable Metrics/MethodLength
          def self.call(requester:, account_id:)
            # retrieve
            account = Account.first(id: account_id)
            raise Exceptions::NotFoundError, 'Account not found' if account.nil?

            # verify
            policy = Policies::Testament.new(requester:,
                                             owner_id: account.id,
                                             executor_id: account.executor_id,
                                             previous_status: account.testament_status)

            unless policy.can_read?
              raise Exceptions::BadRequestError,
                    'You are not allowed to read this testament'
            end

            account.update(testament_status: 'Read').save

            # return
            Account.first(id: account_id)
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end

# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      module Testament
        # Service object to get the Account Information
        class Complete
          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
          def self.call(requester:, account_id:, min_amount_heirs:)
            # retrieve
            account = Account.first(id: account_id)
            raise Exceptions::NotFoundError, 'Account not found' if account.nil?

            # verify
            policy = Policies::Testament.new(requester:,
                                             owner_id: account.id,
                                             executor_id: account.executor_id,
                                             previous_status: account.testament_status)

            unless policy.can_complete?
              raise Exceptions::BadRequestError,
                    'You are not allowed to set the status selected for this testament'
            end

            # Checks if all the properties have the 100% of its distribution
            properties_pending = account.properties.count do |property|
              property.heir_distribution.sum { |heir| heir[:attributes][:percentage] } != 100
            end

            if properties_pending.positive?
              raise Exceptions::BadRequestError, 'The distribution of all properties should be 100%'
            end

            if min_amount_heirs.nil? or min_amount_heirs.zero?
              raise Exceptions::BadRequestError,
                    'Please enter the minimum amount of heirs needed to read your testament.'
            end

            account.update(testament_status: 'Completed').save

            # return
            Account.first(id: account_id)
          end
          # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
        end
      end
    end
  end
end

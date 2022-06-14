# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      class UpdateTestamentStatus
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, account_id:, new_status:)
          # retrieve
          account = Account.first(id: account_id)
          raise Exceptions::NotFoundError, 'Account not found' if account.nil?

          # verify
          policy = Policies::AccountStatus.new(requester:,
                                               owner_id: account.id,
                                               executor_id: account.executor_id,
                                               previous_status: account.testament_status, new_status:)

          unless policy.can_edit?
            raise Exceptions::BadRequestError,
                  'You are not allowed to set the status selected for this testament'
          end

          # Checks if all the properties have the 100% of its distribution
          properties_pending = account.properties.count do |property|
            property.heir_distribution.sum { |heir| heir[:attributes][:percentage] } != 100
          end

          if new_status == 'Completed' && properties_pending.positive?
            raise Exceptions::BadRequestError, 'The distribution of all properties should be 100%'
          end

          account.update(testament_status: new_status)

          # return
          Account.first(id: account_id)
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

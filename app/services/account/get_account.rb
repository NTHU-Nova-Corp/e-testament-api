# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      class GetAccount
        def self.call(requester:, username:)
          # retrieve
          account = Account.first(username:)
          raise Exceptions::NotFoundError, 'Account not found' if account.nil?

          # verify
          policy = Policies::Account.new(requester, account)
          raise Exceptions::ForbiddenError, 'You are not allowed to access that project' unless policy.can_view?

          # return
          account
        end
      end
    end
  end
end

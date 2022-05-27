# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to get the Account Information
      class GetAccount
        def self.call(username:)
          account = Account.first(username:)
          raise Exceptions::NotFoundError, 'Account not found' if account.nil?

          account.to_json
        end
      end
    end
  end
end




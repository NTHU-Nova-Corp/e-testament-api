# frozen_string_literal: true

module ETestament
  module Services
    module Accounts
      # Service object to authenticate username and password
      class Authenticate
        def self.call(credentials)
          account = Account.first(username: credentials[:username])
          raise unless account.password?(credentials[:password])

          account_and_token(account)
        rescue StandardError
          raise Exceptions::UnauthorizedError, credentials
        end

        def self.account_and_token(account)
          {
            type: 'authenticated_account',
            attributes: {
              account:,
              auth_token: AuthToken.create(account)
            }
          }
        end
      end
    end
  end
end

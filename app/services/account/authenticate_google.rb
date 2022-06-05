# frozen_string_literal: true

require 'google/apis/oauth2_v2'

module ETestament
  module Services
    module Accounts
      # Find account and check password
      class AuthenticateGoogle
        def self.call(credentials)
          client = Signet::OAuth2::Client.new(access_token: credentials[:access_token])
          service = Google::Apis::Oauth2V2::Oauth2Service.new
          service.authorization = client
          account_info = service.get_userinfo_v2

          account_and_token(google_account(email: account_info.email, first_name: account_info.given_name,
                                           last_name: account_info.family_name))
        rescue StandardError => e
          Api.logger.error "Could not create google account: #{e.inspect}"

          raise Exceptions::UnauthorizedError, credentials
        end

        def self.google_account(email:, first_name:, last_name:)
          account = Account.first(email:)
          if account.nil?
            account = Account.new
            account[:email] = email
            account[:first_name] = first_name
            account[:last_name] = last_name
            account[:username] = email
            account.save
          end
          account
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

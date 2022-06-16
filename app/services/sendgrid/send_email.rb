# frozen_string_literal: true

require 'http'

module ETestament
  module Services
    module SendGrid
      ## Send email verification email
      # params:
      #   - registration: hash with keys :username :email :verification_url
      class SendEmail
        def mail_api_key = ENV.fetch('SENDGRID_API_KEY')

        def mail_url = ENV.fetch('SENDGRID_API_URL')

        def call(mail_json:)
          unless ETestament::Api.environment == :test
            res = HTTP.auth("Bearer #{mail_api_key}")
                      .post(mail_url, json: mail_json)
            raise Exceptions::EmailProviderError if res.status >= 300
          end
        rescue StandardError
          raise(Exceptions::BadRequestError,
                'Could not send verification email; please check email address')
        end
      end
    end
  end
end

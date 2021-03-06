# frozen_string_literal: true

require 'http'

module ETestament
  module Services
    module Accounts
      ## Send email verification email
      # params:
      #  registration: hash with keys
      #   :username
      #   :email
      #   :verification_url
      class VerifyRegistration
        def initialize(registration)
          @registration = registration
        end

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          raise Exceptions::BadRequestError, 'Username exists' unless username_available?
          raise Exceptions::BadRequestError, 'Email already used' unless email_available?

          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def username_available?
          Account.first(username: @registration[:username]).nil?
        end

        def email_available?
          Account.first(email: @registration[:email]).nil?
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Registration Received</H1>
            <p>Please <a href=\"#{@registration[:verification_url]}\">click here</a>
            to validate your email.
            You will be asked to set a password to activate your account.</p>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @registration[:email] }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Registration Verification',
            content: [
              { type: 'text/html',
                value: html_email }
            ]
          }
        end
      end
    end
  end
end

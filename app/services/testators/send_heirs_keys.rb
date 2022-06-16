# frozen_string_literal: true

require 'http'

module ETestament
  module Services
    module Testators
      ## Send email acceptance email
      # params:
      #  registration: hash with keys
      #   :username
      #   :email
      #   :verification_url
      class SendHeirKey
        def initialize(testator_email, key_token)
          @executor_full_name = executor_full_name
          @testator_email = testator_email
          @key_token = key_token
        end

        def app_url = "#{ENV.fetch('APP_URL')}/testators/submit-key/#{@key_token}"

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Read</H1>
            <p>#{@owner_full_name} sent you a request to be his/her Executor, Please <a href=\"#{app_url}\">click here</a>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @testator_email }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Request Acceptance',
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

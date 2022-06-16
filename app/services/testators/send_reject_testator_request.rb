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
      class SendRejectTestatorRequest
        def initialize(testator_email, executor_full_name)
          @executor_full_name = executor_full_name
          @testator_email = testator_email
        end

        def app_url = ENV.fetch('APP_URL')

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Request Reject</H1>
            <p>#{@executor_full_name} has rejected for your request, please contact the person for more information</p>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @testator_email }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Request Reject',
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

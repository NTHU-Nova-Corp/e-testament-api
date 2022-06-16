# frozen_string_literal: true

require 'http'

module ETestament
  module Services
    module Executors
      ## Send email invitation email
      # params:
      #  registration: hash with keys
      #   :username
      #   :email
      #   :verification_url
      class SendCancelRequest
        def initialize(executor_email, owner_full_name)
          @owner_full_name = owner_full_name
          @executor_email = executor_email
        end

        def app_url = ENV.fetch('APP_URL')

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Cancellation</H1>
            <p>#{@owner_full_name} cancel a request to be his/her Executor</p>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @executor_email }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Cancellation',
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

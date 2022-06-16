# frozen_string_literal: true

require 'http'

module ETestament
  module Services
    module Executors
      ## Send email registration invitation email
      class SendRegisInvitation
        def initialize(registration, owner_full_name)
          @registration = registration
          @owner_full_name = owner_full_name
        end

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Invitation</H1>
            <p>#{@owner_full_name} send you a request to be his/her Executor, Please <a href=\"#{@registration['verification_url']}\">click here</a>
            to register and accept the request.</p>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @registration['email'] }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Invitation',
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

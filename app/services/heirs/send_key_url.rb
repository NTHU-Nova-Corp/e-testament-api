# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to update a heir
      class SendKeyUrl
        def initialize(testator_data, executor_data, heir_data, individual_key)
          @testator_data = testator_data
          @executor_data = executor_data
          @heir_data = heir_data
          @individual_key = individual_key
        end

        def executor_full_name
          "#{@executor_data.first_name} #{@executor_data.last_name}"
        end

        def testator_full_name
          "#{@testator_data.first_name} #{@testator_data.last_name}"
        end

        def heir_full_name
          "#{@heir_data.first_name} #{@heir_data.last_name}"
        end

        def token
          SecureAppMessage.encrypt({ presentation_name: heir_full_name, heir_id: @heir_data.id }.to_json.to_s)
        end

        def app_url = "#{ENV.fetch('APP_URL')}/testators/submit-key/#{token}"

        def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')

        def call
          Services::SendGrid::SendEmail.new.call(mail_json:)
        end

        def html_email
          <<~END_EMAIL
            <H1>E-Testament Testament Release Announcement</H1>
            <p>Hello #{heir_full_name} you are invited to read the testament by #{testator_full_name}</p>
            <p>Steps to continue:</p>
            <p>1. please use the key below to submit in the form.</p>
            <p><b>#{@individual_key}</b></p>
            <p>2. <a href=\"#{app_url}\">Click here</a> to open the submitting page.</p>
            <p>3. then waiting for the other heirs to complete their submitting.</p>
            <p>4. please contact executor #{executor_full_name} for more information.</p>
          END_EMAIL
        end

        def mail_json # rubocop:disable Metrics/MethodLength
          {
            personalizations: [{
              to: [{ 'email' => @heir_data.email }]
            }],
            from: { 'email' => from_email },
            subject: 'E-Testament Testament Release Announcement',
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

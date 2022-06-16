# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class ReleaseTestatorTestament
        extend Securable

        def self.call(requester:, testator_id:)
          key = generate_key
          current_account = ETestament::Accounts.first(account_id: testator_id)
          shamir = ShamirEncryption::ShamirSecretSharing
          shares = shamir::Base64.split(key, current_account.heirs.count, current_account.min_amount_heirs)

          

          # Update the status of the testament to Released
          Service::Accounts::UpdateTestamentStatus.call(requester:, account_id: testator_id, new_status: 'Released')

          # Generate the unique key of the testament

          # Get the list of heirs
          Services::Heirs::GetHeirs(requester:, account_id:).map do |heir|
          end

          # For each heir:  - create a shamier unique key
          #                 - send and email with the shamier unique key
        end
      end
    end
  end
end
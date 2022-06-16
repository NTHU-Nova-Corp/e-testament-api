# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class ReleaseTestatorTestament
        extend Securable

        def self.call(requester:, testator_id:)
          # Generate the unique key of the testament
          key = generate_key
          current_account = ETestament::Accounts.first(account_id: testator_id)
          shamir = ShamirEncryption::ShamirSecretSharing
          shares = shamir::Base64.split(key, current_account.heirs.count, current_account.min_amount_heirs)

          # TODO: Code for crafting link and sending out emails

          # Update the status of the testament to Released
          Service::Accounts::UpdateTestamentStatus.call(requester:, account_id: testator_id, new_status: 'Released')

          # Get the list of heirs
          Services::Heirs::GetHeirs(requester:, account_id:).map do |heir|
          end

          # For each heir:  - create a shamir unique key (Done, just map to each share)
          #                 - send and email with the shamir unique key
        end
      end
    end
  end
end

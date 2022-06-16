# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class ReleaseTestatorTestament
        extend Securable

        def self.call(requester:, testator_id:)
          # retrieve
          executor = Account.first(id: requester['id'])
          account = Account.first(id: testator_id)
          raise Exceptions::NotFoundError, 'Account not found' if account.nil?

          # verify
          policy = Policies::Testament.new(requester:,
                                           owner_id: testator_id,
                                           executor_id: account.executor_id,
                                           previous_status: account.testament_status)

          unless policy.can_release?
            raise Exceptions::BadRequestError, 'You are not allowed set this testament to be released'
          end

          # Generate the unique key of the testament
          combined_key = generate_key
          heirs = account.heirs
          shared_keys = ShamirEncryption::ShamirSecretSharing::Base64.split(combined_key, heirs.count,
                                                                            account.min_amount_heirs)

          # Update the status of the testament to Released
          Services::Accounts::Testament::Release.call(requester:, account_id: testator_id, combined_key:)

          # Get the list of heirs
          heirs.each_with_index do |heir_data, _index|
            individual_key = shared_keys[_index]
            Services::Heirs::UpdateIndividualKey.call(requester:, heir_data:, individual_key:)
            Services::Heirs::SendKeyUrl.new(account, executor, heir_data, individual_key).call
          end
        end
      end
    end
  end
end

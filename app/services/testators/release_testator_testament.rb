# frozen_string_literal: true

module ETestament
  module Services
    module Testators
      # Service object to reject request for being an executor
      # TODO: Handle error
      class ReleaseTestatorTestament
        def self.call(requester:, testator_id:)
          # Update the status of the testament to Released
          Service::Accounts::UpdateTestamentStatus.call(requester:, account_id: testator_id, new_status: 'Released')

          # Generate the unique key of the testament
          # Get the list of heirs
          # For each heir:  - create a shamier unique key
          #                 - send and email with the shamier unique key
        end
      end
    end
  end
end

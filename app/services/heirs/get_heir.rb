# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetHeir
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::Heir.new(requester:, heir_owner_account: heir_data.account)
          raise Exceptions::ForbiddenError, 'You are not allowed to view the heir' unless policy.can_view?

          # return
          heir_data.to_json
        end
      end
    end
  end
end

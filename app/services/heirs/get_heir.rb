# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetHeir
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::Heir.new(requester:, heir_owner_id: heir_data.account.id,
                                      heir_owner_executor_id: heir_data.account.executor_id)
          raise Exceptions::ForbiddenError, 'You are not allowed to view the heir' unless policy.can_view?

          # return
          heir_data
        end
      end
    end
  end
end

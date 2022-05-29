# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to update a heir
      class UpdateHeir
        def self.call(requester:, heir_data:, updated_data:)
          # verify
          policy = Policies::Heir.new(requester:, heir_owner_account: heir_data.account)
          raise Exceptions::ForbiddenError, 'You are not allowed to view the property' unless policy.can_update?

          # execute
          raise(updated_data.keys.to_s) unless heir_data.update(updated_data)
        end
      end
    end
  end
end

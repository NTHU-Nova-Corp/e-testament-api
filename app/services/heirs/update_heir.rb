# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to update a heir
      class UpdateHeir
        def self.call(requester:, heir_data:, updated_data:)
          # verify
          policy = Policies::Heir.new(requester:, heir_owner_id: heir_data.account.id,
                                      heir_owner_executor_id: heir_data.account.executor_id)
          raise Exceptions::ForbiddenError, 'You are not allowed to view the property' unless policy.can_update?

          # execute
          raise Exceptions::BadRequestError unless heir_data.update(updated_data)
        end
      end
    end
  end
end

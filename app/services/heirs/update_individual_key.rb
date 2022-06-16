# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to update a heir
      class UpdateIndividualKey
        def self.call(requester:, heir_data:, individual_key:)
          # verify
          policy = Policies::Heir.new(requester:,
                                      testament_status: heir_data.account.testament_status,
                                      heir_owner_id: heir_data.account.id,
                                      heir_owner_executor_id: heir_data.account.executor_id)
          unless policy.can_set_individual_key?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to set individual key for the heir'
          end

          # retrieve
          heir = Heir.first(id: heir_data.id)

          # execute
          raise Exceptions::BadRequestError unless heir.update(individual_key:)
        end
      end
    end
  end
end

# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to update a heir
      class UpdateHeir
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, heir_data:, updated_data:)
          # verify
          policy = Policies::Heir.new(requester:,
                                      testament_status: heir_data.account.testament_status,
                                      heir_owner_id: heir_data.account.id,
                                      heir_owner_executor_id: heir_data.account.executor_id)
          raise Exceptions::ForbiddenError, 'You are not allowed to view the heir' unless policy.can_update?

          account = Account.first(id: heir_data.account_id)
          unless account.heirs.count do |heir|
                   heir.email == updated_data['email'] && heir.id != heir_data.id
                 end.zero?
            raise Exceptions::BadRequestError,
                  'There is already a heir with the same email'
          end

          # execute
          raise Exceptions::BadRequestError unless heir_data.update(updated_data)
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

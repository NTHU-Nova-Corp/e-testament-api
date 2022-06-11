# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to create a new heir for an account
      class CreateHeir
        # rubocop:disable Metrics/MethodLength
        def self.call(requester:, account_id:, new_data:)
          account = Account.first(id: account_id)

          policy = Policies::Heir.new(requester:, heir_owner_id: account_id,
                                      heir_owner_executor_id: account.executor_id)

          unless policy.can_create?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to create heirs for the account requested'
          end

          unless account.heirs.count { |heir| heir.email == new_data['email'] }.zero?
            raise Exceptions::BadRequestError,
                  'There is already a heir with the same email'
          end

          new_heir = account.add_heir(new_data)
          raise Exceptions::BadRequestError, 'Could not save heir' unless new_heir.save

          new_heir
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end

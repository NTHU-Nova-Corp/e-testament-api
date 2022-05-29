# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class DeleteAssociatedProperty
        def self.call(requester:, heir_data:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_account: heir_data.account,
                                              property_owner_account: property_data.account)
          unless policy.can_remove_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to access that project'
          end

          # execute
          unless PropertyHeir.where(property_id: property_data[:id]).delete
            raise('Could not disassociate heir from property')
          end
        end
      end
    end
  end
end

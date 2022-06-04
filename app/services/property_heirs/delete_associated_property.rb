# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class DeleteAssociatedProperty
        def self.call(requester:, heir_data:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_remove_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to access that project'
          end

          # execute
          result = PropertyHeir.where(property_id: property_data[:id]).delete
          raise('Could not disassociate heir from property') unless result
        end
      end
    end
  end
end

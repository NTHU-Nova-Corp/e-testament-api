# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class GetAssociatedProperty
        def self.call(requester:, heir_data:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_view_heirs_associated_to_property?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # return
          output = { data: property_data }
          JSON.pretty_generate(output)
        end
      end
    end
  end
end

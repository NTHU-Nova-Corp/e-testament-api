# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetAssociatedProperty
        def self.call(requester:, heir_data:, property_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_account: heir_data.account,
                                              property_owner_account: property_data.account)
          unless policy.can_view_property_associations?
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

# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get property list for a heir
      class GetAssociatedProperties
        def self.call(requester:, heir_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:, heir_owner_account: heir_data.account)
          unless policy.can_view_heir_associations?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # return
          property_heirs = PropertyHeir.where(heir_id: heir_data[:id]).all
          properties = property_heirs.map(&:property)

          raise Exceptions::NotFoundError if properties.nil?

          properties.to_json
        end
      end
    end
  end
end

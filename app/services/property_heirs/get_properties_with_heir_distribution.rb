# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the properties related with an an account
      class GetPropertiesWithHeirsDistribution
        # rubocop:disable Metrics/MethodLength
        def self.call(requester:, account_id:)
          account = Account.first(id: account_id)

          policy = Policies::PropertyHeir.new(requester:,
                                              testament_status: account[:testament_status],
                                              heir_owner_id: account_id,
                                              property_owner_id: account_id,
                                              heir_owner_executor_id: account[:executor_account_id],
                                              property_owner_executor_id: account[:executor_account_id])

          unless policy.can_view_associations_between_heirs_and_properties?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to view property requested.'
          end

          account.properties.map do |property|
            { type: 'property_distribution',
              attributes: { id: property.id, name: property.name, description: property.description,
                            heirs: property.heir_distribution } }
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end

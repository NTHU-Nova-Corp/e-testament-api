# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class AssociatePropertyHeir
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, heir_data:, property_data:, new_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              testament_status: heir_data.account[:testament_status],
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: property_data.account[:executor_id],
                                              property_owner_executor_id: heir_data.account[:executor_id])
          unless policy.can_create_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to view the property'
          end

          # execute
          percentage_associated = PropertyHeir.where(property_id: property_data[:id])
                                              .all.sum { |prop| prop[:percentage] }
          unless percentage_associated + new_data['percentage'].to_i <= 100
            raise Exceptions::BadRequestError,
                  "The percentage distribution of #{property_data[:name]} can not be greater than 100%"
          end

          association = PropertyHeir.new(heir_id: heir_data[:id], property_id: property_data[:id],
                                         percentage: new_data['percentage'].to_i)
          raise Exceptions::BadRequestError, 'Could not associate the property with the heir' unless association.save

          association
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

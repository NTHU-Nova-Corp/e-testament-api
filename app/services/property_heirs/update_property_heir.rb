# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get the heirs related with an an account
      class UpdatePropertyHeir
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, heir_data:, property_data:, new_data:)
          # verify
          policy = Policies::PropertyHeir.new(requester:,
                                              heir_owner_id: heir_data.account[:id],
                                              property_owner_id: property_data.account[:id],
                                              heir_owner_executor_id: nil,
                                              property_owner_executor_id: nil)
          unless policy.can_update_association?
            raise Exceptions::ForbiddenError, 'You are not allowed to edit the property'
          end

          # execute
          percentage_associated = PropertyHeir.where(property_id: property_data[:id])
                                              .exclude(heir_id: heir_data[:id])
                                              .all.sum { |prop| prop[:percentage] }

          unless percentage_associated + new_data['percentage'].to_i <= 100
            raise Exceptions::BadRequestError,
                  "The percentage distribution of #{property_data[:name]} can not be greater than 100%"
          end

          association = PropertyHeir.first(heir_id: heir_data[:id], property_id: property_data[:id])

          unless association[:percentage] != new_data['percentage']
            raise Exceptions::BadRequestError,
                  "The percentage distribution of #{property_data[:name]} can not be greater than 100%"
          end

          unless association.update(new_data)
            raise Exceptions::BadRequestError,
                  'Could not associate the property with the heir'
          end

          association
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end

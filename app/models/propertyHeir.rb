# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a property
  class PropertyHeir < Sequel::Model
    many_to_one :property
    many_to_one :heir

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :percentage

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'property',
            attributes: {
              percentage:
            }
          },
          included: {
            property:,
            heir:
          }
        }, options
      )
    end

    # rubocop:enable Metrics/MethodLength
  end
end

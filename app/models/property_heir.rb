# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a property
  class PropertyHeir < Sequel::Model
    many_to_one :property
    many_to_one :heir

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :percentage, :property_id, :heir_id

    def to_h
      {
        type: 'property_heir',
        attributes: {
          id:,
          property_id:,
          heir_id:,
          percentage:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          property:,
          heir:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

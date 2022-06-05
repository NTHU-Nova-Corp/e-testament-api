# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a propertyType
  class PropertyType < Sequel::Model
    one_to_many :properties

    plugin :association_dependencies, properties: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :description

    def to_h
      {
        type: 'property_type',
        attributes: {
          id:,
          name:,
          description:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          properties:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

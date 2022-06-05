# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a propertyType
  class Relation < Sequel::Model
    one_to_many :heirs

    plugin :association_dependencies, heirs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :description

    def to_h
      {
        type: 'relation',
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

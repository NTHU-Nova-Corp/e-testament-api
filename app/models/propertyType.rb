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

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'propertyType',
            attributes: {
              id:,
              name:,
              description:
            }
          },
          included: {
            account:
          }
        }, options
      )
    end

    # rubocop:enable Metrics/MethodLength
  end
end

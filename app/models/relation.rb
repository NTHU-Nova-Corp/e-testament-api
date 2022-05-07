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

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'relation',
            attributes: {
              id:,
              name:,
              description:
            }
          }
        }, options
      )
    end

    # rubocop:enable Metrics/MethodLength
  end
end

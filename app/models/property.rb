# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a property
  class Property < Sequel::Model
    one_to_many :documents
    one_to_many :property_heirs

    many_to_one :account
    many_to_one :property_type

    plugin :association_dependencies, documents: :destroy, property_heirs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :description, :property_type_id

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'property',
            attributes: {
              id:,
              name:,
              description:,
              account_id:,
              property_type_id:
            }
          }
        }, options
      )
    end

    # rubocop:enable Metrics/MethodLength
  end
end

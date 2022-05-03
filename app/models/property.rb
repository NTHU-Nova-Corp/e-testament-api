# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a property
  class Property < Sequel::Model
    one_to_many :documents
    many_to_one :account
    many_to_many :heirs,
                 class: :'ETestament::Property',
                 join_table: :heirs_properties,
                 left_key: :property_id, right_key: :heir_id
    # many_to_one :property_type
    plugin :association_dependencies, documents: :destroy, heirs: :nullify

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :description

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'property',
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

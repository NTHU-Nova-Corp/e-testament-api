# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a property
  class Property < Sequel::Model
    one_to_many :documents
    many_to_one :account
    # many_to_one :property_type
    plugin :association_dependencies, documents: :destroy

    plugin :uuid, field: :id
    plugin :timestamps
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

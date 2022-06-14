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
    def to_h
      {
        type: 'project',
        attributes: {
          id:,
          name:,
          description:,
          account_id:,
          property_type_id:,
          type: property_type.name
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          account:,
          property_type:,
          documents:,
          property_heirs:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def heir_distribution
      property_heirs.map do |property_heir|
        {
          id: property_heir.heir.id, first_name: property_heir.heir.first_name,
          last_name: property_heir.heir.last_name, email: property_heir.heir.email,
          percentage: property_heir.percentage
        }
      end
    end
  end
end

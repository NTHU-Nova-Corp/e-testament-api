# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # Heir model
  class Heir < Sequel::Model
    many_to_one :account
    many_to_one :relation

    one_to_many :property_heirs

    plugin :association_dependencies, property_heirs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password, :relation_id

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'heir',
        attributes: {
          id:,
          account_id:,
          relation_id:,
          first_name:,
          last_name:,
          email:
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          account:,
          relation:,
          property_heirs:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

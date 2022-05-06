# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # Heir model
  class Heir < Sequel::Model
    many_to_one :account
    many_to_one :relation

    one_to_many :propertyHeirs

    plugin :association_dependencies, propertyHeirs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password, :relation_id

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
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
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # Account model
  class Heir < Sequel::Model
    many_to_one :account

    one_to_many :propertyHeirs

    plugin :association_dependencies,
           properties: :nullify

    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password
    plugin :timestamps, update_on_create: true

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

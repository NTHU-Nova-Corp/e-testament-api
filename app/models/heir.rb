# frozen_string_literal: true

require 'sequel'
require 'json'

module ETestament
  # Account model
  class Heir < Sequel::Model
    many_to_one :accounts
    many_to_many :properties,
                 class: :'ETestament::Property',
                 join_table: :heirs_properties,
                 left_key: :heir_id, right_key: :property_id

    plugin :association_dependencies,
           properties: :nullify

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password
    plugin :timestamps, update_on_create: true

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
  end
end

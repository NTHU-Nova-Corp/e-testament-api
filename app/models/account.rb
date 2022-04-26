# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module ETestament
  # Account model
  class Account < Sequel::Model
    one_to_many :properties

    plugin :association_dependencies, properties: :destroy

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password
    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = ETestament::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'account',
            attributes: {
              id:,
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

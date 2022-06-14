# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module ETestament
  # Account model
  class Account < Sequel::Model
    one_to_many :properties
    one_to_many :heirs

    many_to_one :executor, class: :'ETestament::Account'
    one_to_many :testators, key: :executor_id, class: :'ETestament::Account'

    one_to_many :request_testators, class: :'ETestament::PendingExecutorAccount', key: :executor_account_id
    one_to_many :pending_executors, class: :'ETestament::PendingExecutorAccount', key: :owner_account_id

    plugin :association_dependencies, properties: :destroy, heirs: :destroy

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password, :username, :executor_id, :testament_status
    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = ETestament::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'account',
        attributes: {
          id:,
          username:,
          first_name:,
          last_name:,
          email:,
          testament_status:
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          properties:,
          heirs:,
          executor:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

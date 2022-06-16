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

    one_to_many :executor_request_received, class: :'ETestament::PendingExecutorAccount', key: :executor_account_id
    one_to_many :executor_request_sent, class: :'ETestament::PendingExecutorAccount', key: :owner_account_id

    plugin :association_dependencies, properties: :destroy, heirs: :destroy

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email, :password, :combined_key, :username, :executor_id,
                        :testament_status, :min_amount_heirs
    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = ETestament::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def combined_key=(new_combined_key)
      self.combined_key_digest = ETestament::Password.digest(new_combined_key)
    end

    def combined_key?(try_combined_key)
      digest = ETestament::Password.from_digest(combined_key_digest)
      digest.correct?(try_combined_key)
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
          testament_status:,
          min_amount_heirs:
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

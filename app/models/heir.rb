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
    set_allowed_columns :first_name, :last_name, :email, :password, :relation_id, :key_content_submitted,
                        :individual_key

    def key_content_submitted
      SecureDB.decrypt(key_content_submitted_secure)
    end

    def key_content_submitted=(plaintext)
      self.key_content_submitted_secure = SecureDB.encrypt(plaintext)
    end

    def individual_key=(new_individual_key)
      self.individual_key_digest = ETestament::Password.digest(new_individual_key)
    end

    def individual_key?(try_individual_key)
      digest = ETestament::Password.from_digest(individual_key_digest)
      digest.correct?(try_individual_key)
    end

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
          email:,
          relation: relation.name
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

# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a document related with a Property
  class Document < Sequel::Model
    many_to_one :property

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :file_name, :type, :description, :content

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'document',
        attributes: {
          id:,
          file_name:,
          type:,
          description:,
          property_id:
        }
      }
    end

    def full_details
      to_h.merge(
        data: {
          content:
        },
        relationships: {
          property:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end

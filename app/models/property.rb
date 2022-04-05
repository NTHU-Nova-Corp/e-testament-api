# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'securerandom'

# General ETestament module
module ETestament
  STORE_DIR = 'app/db/store'

  # Basic property model used to store user assets
  class Property
    # Creates a new property record
    def initialize(new_property)
      @id = new_property['id'] || new_id
      @name = new_property['name']
      @description = new_property['description']
      @property_type = new_property['property_type']
      @heir_users_assigned = new_property['heir_users_assigned']
    end

    attr_reader :id, :name, :description, :property_type, :heir_users_assigned

    def to_json(options = {})
      JSON(
        {
          type: 'property',
          id:,
          name:,
          description:,
          property_type:,
          heir_users_assigned:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(ETestament::STORE_DIR) unless Dir.exist? ETestament::STORE_DIR
    end

    # Stores a property record
    # TODO: Ernesto
    def save; end

    # Find a property in the storage
    # TODO: Daniel
    def self.find(find_id); end

    # Find all property indexes
    # TODO: Cesar
    def self.all; end

    private

    def generate_new_id
      SecureRandom.uuid
    end
  end
end

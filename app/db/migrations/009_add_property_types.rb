# frozen_string_literal: true

require 'sequel'
require 'securerandom'
require 'yaml'

TYPES = YAML.load_file('app/db/constants/property_type_constants.yml')

Sequel.migration do
  up do
    TYPES.each do |type|
      from(:property_types).insert([:id, :name, :description, :created_at, :updated_at],
                                   [SecureRandom.uuid, type['name'], type['description'], Time.now, Time.now])
    end
  end
end

# frozen_string_literal: true

# DB[:items].insert([:a, :b], [1,2])

require 'sequel'
require 'securerandom'
require 'yaml'

RELATIONS = YAML.load_file('app/db/constants/relations_constants.yml')

Sequel.migration do
  up do
    RELATIONS.each do |relation|
      from(:relations).insert([:id, :name, :description, :created_at, :updated_at],
                              [SecureRandom.uuid, relation['name'], relation['description'], Time.now, Time.now])
    end
  end
end

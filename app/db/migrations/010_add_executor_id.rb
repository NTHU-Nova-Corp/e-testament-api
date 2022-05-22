# frozen_string_literal: true

require 'sequel'
require 'securerandom'
require 'yaml'

TYPES = YAML.load_file('app/db/constants/property_type_constants.yml')

Sequel.migration do
  change do
    alter_table(:accounts) do
      add_foreign_key(:executor_id, :accounts, type: :uuid, null: true)
    end
  end
end

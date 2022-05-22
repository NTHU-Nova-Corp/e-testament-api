# frozen_string_literal: true

require 'sequel'
require 'securerandom'
require 'yaml'

Sequel.migration do
  change do
    alter_table(:accounts) do
      add_foreign_key(:executor_id, :accounts, type: :uuid, null: true)
    end
  end
end

# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:documents) do
      add_column(:type, String, null: false, default: '')
    end
  end
end

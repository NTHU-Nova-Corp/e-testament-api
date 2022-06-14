# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:accounts) do
      add_column(:testament_status, String, null: false, default: 'Under Edition')
    end
  end
end

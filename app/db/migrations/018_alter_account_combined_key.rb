# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:heirs) do
      add_column(:combined_key_digest, String, null: true)
    end
  end
end

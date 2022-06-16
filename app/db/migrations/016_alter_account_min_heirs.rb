# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:accounts) do
      add_column(:min_amount_heirs, Integer, null: true)
    end
  end
end

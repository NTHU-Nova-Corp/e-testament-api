# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:property_heirs) do
      foreign_key :property_id, :property
      foreign_key :heir_id, :heir
      primary_key [:property_id, :heir_id]
    end
  end
end

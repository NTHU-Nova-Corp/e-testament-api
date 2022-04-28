# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(heir_id: :heirs, property_id: :properties)
  end
end
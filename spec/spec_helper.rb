# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

# rubocop:disable Metrics/CyclomaticComplexity
def wipe_database
  ETestament::PropertyHeir.map(&:destroy)
  ETestament::Heir.map(&:destroy)
  ETestament::Document.map(&:destroy)
  ETestament::Property.map(&:destroy)
  ETestament::Account.map(&:destroy)
end
# rubocop:enable Metrics/CyclomaticComplexity

def seed_accounts
  DATA[:accounts].each do |account|
    ETestament::Account.create(account)
  end
end

def seed_properties
  properties = DATA[:properties].each
  property_type = ETestament::PropertyType.first
  accounts = ETestament::Account.all.cycle
  loop do
    property = properties.next
    property['property_type_id'] = property_type.id
    account_id = accounts.next.id
    ETestament::CreatePropertyForAccount.call(account_id:, property:)
  end
end

def seed_documents
  documents = DATA[:documents].each
  properties = ETestament::Property.all.cycle
  loop do
    document = documents.next
    property_id = properties.next.id
    ETestament::CreateDocumentForProperty.call(property_id:, document:)
  end
end

def seed_heirs
  heirs = DATA[:heirs].each
  relation = ETestament::Relation.first
  accounts = ETestament::Account.all.cycle
  loop do
    heir = heirs.next
    heir['relation_id'] = relation.id
    account_id = accounts.next.id
    ETestament::CreateHeirForAccount.call(account_id:, heir:)
  end
end

def seed_property_heirs
  property_heirs = DATA[:property_heris].each
  heirs = ETestament::Heir.all.cycle
  properties = ETestament::Property.all.cycle
  loop do
    property_heir = property_heirs.next
    heir_id = heirs.next.id
    property_id = properties.next.id
    ETestament::AddHeirToProperty.call(heir_id:, property_id:, property_heir:)
  end
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  properties: YAML.load(File.read('app/db/seeds/property_seeds.yml')),
  documents: YAML.load(File.read('app/db/seeds/document_seeds.yml')),
  heirs: YAML.load(File.read('app/db/seeds/heir_seeds.yml')),
  property_heris: YAML.load(File.read('app/db/seeds/property_heir_seeds.yml'))
}.freeze

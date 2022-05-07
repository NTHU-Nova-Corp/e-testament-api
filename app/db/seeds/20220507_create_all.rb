# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding davelopment data'
    create_accounts
    create_property_types
    create_properties
    create_documents
    create_relations
    create_heirs
    create_property_heirs
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS = YAML.load_file("#{DIR}/account_seeds.yml")
PROPERTY_TYPES = YAML.load_file("#{DIR}/property_types.yml")
PROPERTIES = YAML.load_file("#{DIR}/property_seeds.yml")
DOCUMENTS = YAML.load_file("#{DIR}/document_seeds.yml")
RELATIONS = YAML.load_file("#{DIR}/relations_seeds.yml")
HEIRS = YAML.load_file("#{DIR}/heir_seeds.yml")
PROPERTY_HEIRS = YAML.load_file("#{DIR}/property_heir_seeds.yml")

def create_accounts
  ACCOUNTS.each do |account|
    ETestament::Account.create(account)
  end
end

def create_property_types
  PROPERTY_TYPES.each do |property_type|
    ETestament::PropertyType.create(property_type)
  end
end

def create_properties
  properties = PROPERTIES.each
  property_type = ETestament::PropertyType.first
  accounts = ETestament::Account.all.cycle
  loop do
    property = properties.next
    property['property_type_id'] = property_type.id
    account_id = accounts.next.id
    ETestament::CreatePropertyForAccount.call(account_id:, property:)
  end
end

def create_documents
  documents = DOCUMENTS.each
  properties = ETestament::Property.all.cycle
  loop do
    document = documents.next
    property_id = properties.next.id
    ETestament::CreateDocumentForProperty.call(property_id:, document:)
  end
end

def create_relations
  RELATIONS.each do |relations|
    ETestament::Relation.create(relations)
  end
end

def create_heirs
  heirs = HEIRS.each
  relation = ETestament::Relation.first
  accounts = ETestament::Account.all.cycle
  loop do
    heir = heirs.next
    heir['relation_id'] = relation.id
    account_id = accounts.next.id
    ETestament::CreateHeirForAccount.call(account_id:, heir:)
  end
end

def create_property_heirs
  property_heirs = PROPERTY_HEIRS.each
  heirs = ETestament::Heir.all.cycle
  properties = ETestament::Property.all.cycle
  loop do
    property_heir = property_heirs.next
    heir_id = heirs.next.id
    property_id = properties.next.id
    ETestament::AddHeirToProperty.call(heir_id:, property_id:, property_heir:)
  end
end
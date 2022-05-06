# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, properties, documents'
    create_accounts
    create_properties
    create_documents
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS = YAML.load_file("#{DIR}/account_seeds.yml")
PROPERTIES = YAML.load_file("#{DIR}/property_seeds.yml")
DOCUMENTS = YAML.load_file("#{DIR}/document_seeds.yml")
HEIRS = YAML.load_file("#{DIR}/heir_seeds.yml")

def create_accounts
  ACCOUNTS.each do |account|
    ETestament::Account.create(account)
  end
end

def create_properties
  properties = PROPERTIES.each
  accounts = ETestament::Account.all.cycle
  loop do
    property = properties.next
    account_id = accounts.next.id
    ETestament::CreatePropertyForAccount.call(id: account_id, property:)
  end
end

def create_documents
  documents = DOCUMENTS.each
  properties = ETestament::Property.all.cycle
  loop do
    document = documents.next
    property_id = properties.next.id
    ETestament::CreateDocumentForProperty.call(id: property_id, document:)
  end
end

def create_heirs
  heirs = HEIRS.each
  properties = ETestament::Property.all.cycle
  loop do
    heir = heirs.next
    property_id = properties.next.id
    ETestament::AddHeirToProperty.call(email:heir.email, property_id:)
  end
end

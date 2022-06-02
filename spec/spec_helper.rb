# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  ETestament::PropertyHeir.map(&:destroy)
  ETestament::Heir.map(&:destroy)
  ETestament::Document.map(&:destroy)
  ETestament::Property.map(&:destroy)
  ETestament::PendingExecutorAccount.map(&:destroy)
  ETestament::Account.map(&:destroy)
end

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
    ETestament::Services::Accounts::CreateProperty.call(account_id:, property:)
  end
end

def seed_documents
  documents = DATA[:documents].each
  properties = ETestament::Property.all.cycle
  loop do
    document = documents.next
    property_id = properties.next.id
    ETestament::Services::Properties::CreateDocument.call(property_id:, document:)
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
    ETestament::Services::Heirs::CreateHeir.call(account_id:, new_data: heir)
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def seed_property_heirs
  property_heirs = DATA[:property_heirs].each
  heirs = ETestament::Heir.all.cycle
  properties = ETestament::Property.all.cycle
  loop do
    property_heir = property_heirs.next

    heir_data = heirs.next
    property_data = properties.next
    account = JSON.parse(property_data.account.to_json)['data']['attributes']
    ETestament::Services::PropertyHeirs::AssociatePropertyHeir.call(requester: account, heir_data:, property_data:,
                                                                    new_data: property_heir)
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  properties: YAML.load(File.read('app/db/seeds/property_seeds.yml')),
  documents: YAML.load(File.read('app/db/seeds/document_seeds.yml')),
  heirs: YAML.load(File.read('app/db/seeds/heir_seeds.yml')),
  property_heirs: YAML.load(File.read('app/db/seeds/property_heir_seeds.yml'))
}.freeze

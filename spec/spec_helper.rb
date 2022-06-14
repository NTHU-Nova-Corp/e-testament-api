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
  ETestament::PendingExecutorAccount.map(&:destroy)

  ETestament::Account.all.each do |acc|
    acc.update(executor_id: nil)
  end

  ETestament::Account.map(&:destroy)
end
# rubocop:enable Metrics/CyclomaticComplexity

def seed_accounts
  DATA[:accounts].each do |account|
    ETestament::Account.create(account)
  end
end

def assign_executors
  accounts = ETestament::Account.all.cycle
  executor = accounts.next

  testator1 = accounts.next
  testator1.update(executor_id: executor[:id])

  testator2 = accounts.next
  testator2.update(executor_id: executor[:id])
end

def seed_properties
  properties = DATA[:properties].each
  property_type = ETestament::PropertyType.first
  accounts = ETestament::Account.all.cycle
  loop do
    property = properties.next
    property['property_type_id'] = property_type.id
    account = JSON.parse(accounts.next.to_json)['attributes']

    ETestament::Services::Properties::CreateProperty.call(requester: account, account_id: account['id'],
                                                          new_data: property)
  end
end

def seed_documents
  documents = DATA[:documents].each
  properties = ETestament::Property.all.cycle
  accounts = ETestament::Account.all.cycle
  loop do
    document = documents.next
    property_data = properties.next
    account = JSON.parse(accounts.next.to_json)['attributes']

    ETestament::Services::Properties::CreateDocument.call(requester: account, property_data:, new_data: document)
  end
end

def seed_heirs
  heirs = DATA[:heirs].each
  relation = ETestament::Relation.first
  accounts = ETestament::Account.all.cycle

  loop do
    heir = heirs.next
    heir['relation_id'] = relation.id
    account = JSON.parse(accounts.next.to_json)['attributes']

    ETestament::Services::Heirs::CreateHeir.call(requester: account, account_id: account['id'], new_data: heir)
  end
end

# rubocop:disable Metrics/MethodLength
def seed_property_heirs
  property_heirs = DATA[:property_heirs].each
  heirs = ETestament::Heir.all.cycle
  properties = ETestament::Property.all.cycle
  loop do
    property_heir = property_heirs.next

    heir_data = heirs.next
    property_data = properties.next
    account = JSON.parse(property_data.account.to_json)['attributes']
    ETestament::Services::PropertyHeirs::AssociatePropertyHeir.call(requester: account, heir_data:, property_data:,
                                                                    new_data: property_heir)
  end
end

# rubocop:enable Metrics/MethodLength

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  properties: YAML.load(File.read('app/db/seeds/property_seeds.yml')),
  documents: YAML.load(File.read('app/db/seeds/document_seeds.yml')),
  heirs: YAML.load(File.read('app/db/seeds/heir_seeds.yml')),
  property_heirs: YAML.load(File.read('app/db/seeds/property_heir_seeds.yml'))
}.freeze

## SSO fixtures
# TODO: Get actual Google SSO JSON for fixtures
# GOOGLE_ACCOUNT_RESPONSE = YAML.load(
#   File.read('spec/fixtures/google_token_response.yml')
# )
# GOOD_GOOGLE_ACCESS_TOKEN = GOOGLE_ACCOUNT_RESPONSE.keys.first
# SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_account.yml'))
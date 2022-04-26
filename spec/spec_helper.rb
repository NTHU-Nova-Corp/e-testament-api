# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  ETestament::Account.map(&:destroy)
  ETestament::Document.map(&:destroy)
  ETestament::Property.map(&:destroy)
end

def seed_accounts
  DATA[:accounts].each do |account|
    ETestament::Account.create(account)
  end
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/account_seeds.yml')),
  properties: YAML.load(File.read('app/db/seeds/property_seeds.yml')),
  documents: YAML.load(File.read('app/db/seeds/document_seeds.yml'))
}.freeze

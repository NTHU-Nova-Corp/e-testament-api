# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:documents].delete
  app.DB[:properties].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:documents] = YAML.safe_load File.read('app/db/seeds/document_seeds.yml')
DATA[:properties] = YAML.safe_load File.read('app/db/seeds/property_seeds.yml')
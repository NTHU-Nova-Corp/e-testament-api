# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'
require 'json'

require_relative '../app/controllers/app'
require_relative '../app/models/property'

def app
  ETestament::Api
end

DATA = YAML.safe_load File.read('app/db/properties/property_list.yml')

describe 'Test ETestament Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{ETestament::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle properties' do
    # Test GET api/v1/properties/[id]
    # Test Get a specific property record
    describe 'GET api/v1/properties/[id]' do
      # TODO
    end
    # Test GET api/v1/properties
    # Test Get the list of properties indexes
    describe 'GET api/v1/properties' do
      # TODO
    end
    # Test POST api/v1/properties
    # Test Creates a new property
    describe 'POST api/v1/properties' do
      it 'HAPPY: should be able to create new property' do
        req_header = { 'CONTENT_TYPE' => 'application/json' }
        post 'api/v1/properties', DATA[1].to_json, req_header

        _(last_response.status).must_equal 201
      end
      it 'SAD: should not be able to create new property when requesting with invalid structure' do
        req_header = { 'CONTENT_TYPE' => 'application/json' }
        post 'api/v1/properties', 'id=100', req_header

        _(last_response.status).must_equal 400
      end

      empty_bodies = ['', '{}', nil]
      empty_bodies.each do |body|
        it 'SAD: should not be able to create new property when requesting with empty body' do
          req_header = { 'CONTENT_TYPE' => 'application/json' }
          post 'api/v1/properties', body, req_header

          _(last_response.status).must_equal 400
        end
      end
    end
  end
end

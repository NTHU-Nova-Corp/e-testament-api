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
TEST_DATA = YAML.safe_load File.read('spec/test_data.yaml')

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
    # Test GET api/v1/properties
    # Test Get the list of properties indexes
    describe 'GET api/v1/properties' do
      it 'HAPPY: should be able to get list of all properties' do
        ETestament::Property.new(DATA[0]).save
        ETestament::Property.new(DATA[1]).save

        get 'api/v1/properties'
        result = JSON.parse last_response.body
        _(result['property_ids'].count).must_equal 2
      end
    end

    # Test GET api/v1/properties/[id]
    # Test Get a specific property record
    describe 'GET api/v1/properties/[id]' do
      it 'HAPPY: should be able to get details of a single property' do
        ETestament::Property.new(DATA[1]).save
        id = Dir.glob('app/db/store/*.txt').first.split(%r{[/\.]})[3]

        get "api/v1/properties/#{id}"
        result = JSON.parse last_response.body

        _(last_response.status).must_equal 200
        _(result['id']).must_equal id
      end

      it 'SAD: should return error if unknown document is requested' do
        get 'api/v1/properties/supermaxwdc'

        _(last_response.status).must_equal 404
      end
    end

    # Test POST api/v1/properties
    # Test Creates a new property
    describe 'POST api/v1/properties' do
      it 'HAPPY: should be able to create new property' do
        req_header = { 'CONTENT_TYPE' => 'application/json' }
        post 'api/v1/properties', DATA[1].to_json, req_header

        _(last_response.status).must_equal 201
      end

      TEST_DATA['failed_428'].each do |test_case|
        it "SAD: should not be able to create new property and return http status 428 when #{test_case['case']}" do
          req_header = { 'CONTENT_TYPE' => 'application/json' }
          post 'api/v1/properties', test_case['body'].to_json, req_header

          _(last_response.status).must_equal 428
        end
      end

      TEST_DATA['failed_400'].each do |body|
        it 'SAD: should not be able to create new property when requesting with invalid body structure' do
          req_header = { 'CONTENT_TYPE' => 'application/json' }
          post 'api/v1/properties', body, req_header

          _(last_response.status).must_equal 400
        end
      end
    end
  end
end

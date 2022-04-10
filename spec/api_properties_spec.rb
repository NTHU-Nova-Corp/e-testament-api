# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all properties' do
    ETestament::Property.create(DATA[:properties][0]).save
    ETestament::Property.create(DATA[:properties][1]).save

    get 'api/v1/properties'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single property' do
    existing_property = DATA[:properties][1]
    ETestament::Property.create(existing_property).save
    id = ETestament::Property.first.id

    get "/api/v1/properties/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_property['name']
  end

  it 'SAD: should return error if unknown property requested' do
    get '/api/v1/properties/2'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new property' do
    new_property = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/properties', new_property.to_json, req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    property = ETestament::Property.first

    _(created['id']).must_equal property.id
    _(created['name']).must_equal new_property['name']
    _(created['repo_url']).must_equal new_property['repo_url']
  end

  it 'SAD: should not be able to create two properties with the same name' do
    new_property1 = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/properties', new_property1.to_json, req_header
    _(last_response.status).must_equal 201

    new_property2 = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/properties', new_property2.to_json, req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to delete existing property' do
  end

  it 'SAD: should return 404 when try to delete a property that doesnt exists' do
  end

  it 'HAPPY: should be able to update existing property' do
  end

  it 'SAD: should return 404 when try to update a property that doesnt exists' do
  end
end

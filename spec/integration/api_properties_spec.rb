# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    seed_accounts
  end

  it 'HAPPY: should be able to get list of all properties' do
    account = ETestament::Account.first
    account.add_property(DATA[:properties][0])
    account.add_property(DATA[:properties][1])
    account.id
    get "api/v1/accounts/#{account.id}/properties"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single property' do
    account = ETestament::Account.first
    account.add_property(DATA[:properties][1])
    existing_property = account.properties.first

    get "/api/v1/accounts/#{account.id}/properties/#{existing_property.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal existing_property.id
    _(result['data']['attributes']['name']).must_equal existing_property.name
  end

  it 'SAD: should return error if unknown property requested' do
    account = ETestament::Account.first
    get "/api/v1/accounts/#{account.id}/properties/2"

    _(last_response.status).must_equal 404
  end

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    account = ETestament::Account.first
    ETestament::Property.create(name: 'New Project')
    ETestament::Property.create(name: 'Newer Project')
    get "api/v1/accounts/#{account.id}/properties/2%20or%20TRUE"

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  it 'HAPPY: should be able to create new property' do
    account = ETestament::Account.first
    new_property = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties", new_property.to_json, req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    property = ETestament::Property.first

    _(created['id']).must_equal property.id
    _(created['name']).must_equal new_property['name']
    _(created['description']).must_equal new_property['description']
  end

  it 'SAD: should not be able to create two properties with the same name' do
    account = ETestament::Account.first
    new_property = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties", new_property.to_json, req_header
    _(last_response.status).must_equal 201

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties", new_property.to_json, req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to delete existing property' do
    account = ETestament::Account.first
    property = account.add_property(DATA[:properties][0])
    id = property.id
    get "/api/v1/accounts/#{account.id}/properties/#{id}"
    _(last_response.status).must_equal 200

    post "/api/v1/accounts/#{account.id}/properties/#{id}/delete"
    _(last_response.status).must_equal 200

    get "/api/v1/accounts/#{account.id}/properties/#{id}"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to update existing property' do
    account = ETestament::Account.first
    request = DATA[:properties][0]
    data = ETestament::Property.create(request).values
    id = data[:id]

    update_request = {}
    update_request[:name] = 'Test update_name'
    update_request[:description] = 'Test description'

    get "/api/v1/accounts/#{account.id}/properties/#{id}"
    _(last_response.status).must_equal 200
    result = JSON.parse(last_response.body)['data']['attributes']
    _(result['name']).wont_equal update_request[:name]
    _(result['description']).wont_equal update_request[:description]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties/#{id}", update_request.to_json, req_header
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]

    get "/api/v1/accounts/#{account.id}/properties/#{id}"
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']['attributes']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]
  end

  it 'SAD: should return 404 when try to update a property that doesnt exists' do
    account = ETestament::Account.first

    new_property = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties/122", new_property.to_json, req_header
    _(last_response.status).must_equal 404
  end

  it 'SAD: should prevent edits to unauthorized fields' do
    account = ETestament::Account.first
    request = DATA[:properties][0]
    data = ETestament::Property.create(request).values
    id = data[:id]

    update_request = {}
    update_request[:name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Hacker wants to commemorate the Xinhai Revolution :)
    update_request[:created_at] = '1911-10-10'

    # Try to update property with unauthorized field
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{account.id}/properties/#{id}", update_request.to_json, req_header
    _(last_response.status).must_equal 400
  end
end

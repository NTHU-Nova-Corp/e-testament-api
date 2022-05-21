# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting properties' do
    describe 'Getting list of properties' do
      before do
        @account_data = DATA[:accounts][0]
        account = ETestament::Account.create(@account_data)
        property0 = DATA[:properties][0]
        property0['property_type_id'] = ETestament::PropertyType.first.id
        account.add_property(property0)
        property1 = DATA[:properties][1]
        property1['property_type_id'] = ETestament::PropertyType.first.id
        account.add_property(property1)
      end

      it 'HAPPY: should be able to get list of all properties' do
        auth = ETestament::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/properties'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized accounts' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/properties'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end
  end

  it 'HAPPY: should be able to get details of a single property' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    property0 = DATA[:properties][0]
    property0['property_type_id'] = property_type.id
    account.add_property(property0)

    existing_property = account.properties.first

    get "/api/v1/properties/#{existing_property.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal existing_property.id
    _(result['data']['attributes']['name']).must_equal existing_property.name
  end

  it 'SAD: should return error if unknown property requested' do
    get '/api/v1/properties/2'

    _(last_response.status).must_equal 404
  end

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    property0 = DATA[:properties][0]
    property0['property_type_id'] = property_type.id
    property_type = ETestament::PropertyType.first
    property1 = DATA[:properties][1]
    property1['property_type_id'] = property_type.id
    account.add_property(property0)
    account.add_property(property1)

    get 'api/v1/properties/2%20or%20TRUE'

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  it 'HAPPY: should be able to create new property' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id
    req_header = { 'CONTENT_TYPE' => 'application/json', 'account_id' => account.id }
    post '/api/v1/properties', new_property.to_json, req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    property = ETestament::Property.first

    _(created['id']).must_equal property.id
    _(created['name']).must_equal new_property['name']
    _(created['description']).must_equal new_property['description']
  end

  it 'SAD: should not be able to create two properties with the same name' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id
    req_header = { 'CONTENT_TYPE' => 'application/json', 'account_id' => account.id }
    post '/api/v1/properties', new_property.to_json, req_header
    _(last_response.status).must_equal 201

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/properties', new_property.to_json, req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to delete existing property' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id
    property = account.add_property(new_property)

    id = property.id
    get "/api/v1/properties/#{id}"
    _(last_response.status).must_equal 200

    post "/api/v1/properties/#{id}/delete"
    _(last_response.status).must_equal 200

    get "/api/v1/properties/#{id}"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to update existing property' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id

    data = account.add_property(new_property)
    id = data[:id]

    update_request = {}
    update_request[:name] = 'Test update_name'
    update_request[:description] = 'Test description'

    get "/api/v1/properties/#{id}"
    _(last_response.status).must_equal 200
    result = JSON.parse(last_response.body)['data']['attributes']
    _(result['name']).wont_equal update_request[:name]
    _(result['description']).wont_equal update_request[:description]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/properties/#{id}", update_request.to_json, req_header
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]

    get "/api/v1/properties/#{id}"
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']['attributes']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]
  end

  it 'SAD: should return 404 when try to update a property that doesnt exists' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id

    new_property = DATA[:properties][1]
    req_header = { 'CONTENT_TYPE' => 'application/json', 'account_id' => account.id }
    post '/api/v1/properties/122', new_property.to_json, req_header
    _(last_response.status).must_equal 404
  end

  it 'SAD: should prevent edits to unauthorized fields' do
    account = ETestament::Account.create(DATA[:accounts][0])
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][0]
    new_property['property_type_id'] = property_type.id

    data = account.add_property(new_property).save
    id = data[:id]

    update_request = {}
    update_request[:name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Hacker wants to commemorate the Xinhai Revolution :)
    update_request[:created_at] = '1911-10-10'

    # Try to update property with unauthorized field
    req_header = { 'CONTENT_TYPE' => 'application/json', 'account_id' => account.id }
    post "/api/v1/properties/#{id}", update_request.to_json, req_header
    _(last_response.status).must_equal 400
  end
end

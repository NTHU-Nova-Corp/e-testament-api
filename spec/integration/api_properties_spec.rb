# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Property Handling' do
  include Rack::Test::Methods

  def login_account(account)
    @account_data = account

    @auth = ETestament::Services::Accounts::Authenticate.call(
      username: @account_data['username'],
      password: @account_data['password']
    )
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
  end

  before(:each) do
    # clear
    wipe_database

    # seed
    seed_accounts
    seed_properties
    seed_heirs
    seed_property_heirs

    # setup data
    @owner_account_data = DATA[:accounts][0]
    @executor_account_data = DATA[:accounts][1]
    @other_account_data = DATA[:accounts][2]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @owner = @accounts.next
    @executor = @accounts.next
    @other = @accounts.next
    @owner.update(executor_id: @executor[:id])

    # setup login account
    login_account(@owner_account_data)
  end

  describe 'Getting properties' do
    describe 'Getting list of properties' do
      # before do
      #   @account_data = DATA[:accounts][0]
      #   account = ETestament::Account.create(@account_data)
      #   property0 = DATA[:properties][0]
      #   property0['property_type_id'] = ETestament::PropertyType.first.id
      #   account.add_property(property0)
      #   property1 = DATA[:properties][1]
      #   property1['property_type_id'] = ETestament::PropertyType.first.id
      #   account.add_property(property1)
      # end

      it 'HAPPY: should be able to get list of all properties' do
        get 'api/v1/properties'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD AUTHORIZATION: should not process for unauthorized accounts' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/properties'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        assert_nil result['data']
      end
    end
  end

  it 'HAPPY: should be able to get details of a single property' do
    property = @owner.properties.first

    get "/api/v1/properties/#{property.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal property.id
    _(result['data']['attributes']['name']).must_equal property.name
  end

  it 'SAD: should return error if unknown property requested' do
    get '/api/v1/properties/2'

    _(last_response.status).must_equal 404
  end

  it 'BAD SQL_INJECTION: should prevent basic SQL injection targeting IDs' do
    get 'api/v1/properties/2%20or%20TRUE'

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    assert_nil last_response.body['data']
  end

  it 'HAPPY: should be able to create new property' do
    property_type = ETestament::PropertyType.first
    new_property = DATA[:properties][2]
    new_property['property_type_id'] = property_type.id

    post '/api/v1/properties', new_property.to_json, @req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['attributes']
    property = ETestament::Property.first(id: created['id'])

    _(created['id']).must_equal property.id
    _(created['name']).must_equal new_property['name']
    _(created['description']).must_equal new_property['description']
  end

  it 'SAD: should not be able to create two properties with the same name' do
    property = @owner.properties.first
    new_property = {}
    new_property['name'] = property.name
    new_property['description'] = property.description
    new_property['property_type_id'] = property.property_type_id

    post '/api/v1/properties', new_property.to_json, @req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to delete existing property' do
    property = @owner.properties.first
    ETestament::PropertyHeir.where(property_id: property[:id]).delete

    post "/api/v1/properties/#{property.id}/delete"
    _(last_response.status).must_equal 200

    get "/api/v1/properties/#{property.id}"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to update existing property' do
    property = @owner.properties.first

    update_request = {}
    update_request[:name] = 'Test update_name 2'
    update_request[:description] = 'Test description 2'

    post "/api/v1/properties/#{property.id}", update_request.to_json, @req_header
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]

    get "/api/v1/properties/#{property.id}"
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']['attributes']
    _(updated['name']).must_equal update_request[:name]
    _(updated['description']).must_equal update_request[:description]
  end

  it 'SAD: should return 404 when try to update a property that doesnt exists' do
    new_property = DATA[:properties][1]

    post '/api/v1/properties/122', new_property.to_json, @req_header
    _(last_response.status).must_equal 404
  end

  it 'SAD MASS_ASSIGNMENT: should prevent edits to unauthorized fields' do
    property = @owner.properties.first

    update_request = {}
    update_request[:name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Hacker wants to commemorate the Xinhai Revolution :)
    update_request[:created_at] = '1911-10-10'

    # Try to update property with unauthorized field
    post "/api/v1/properties/#{property.id}", update_request.to_json, @req_header
    _(last_response.status).must_equal 400
  end

  describe 'GET api/v1/properties/:property_id/heirs' do
    it 'HAPPY: should be able to get heirs by property id' do
      # given
      existing_property = @owner.properties.first

      # when
      get "api/v1/properties/#{existing_property[:id]}/heirs"

      # then
      _(last_response.status).must_equal 200
      _(JSON.parse(last_response.body)['data'].length).must_equal 1
    end

    it 'BAD AUTHORIZATION: should not be able to get heirs by property id from other account' do
      # given
      existing_property = @owner.properties.first
      login_account(@other_account_data)

      # when
      get "api/v1/properties/#{existing_property[:id]}/heirs"

      # then
      _(last_response.status).must_equal 403
    end
  end

  describe 'POST api/v1/properties/:property_id/heirs/:heir_id' do
    it 'HAPPY: should be able to associate heirs with properties' do
      # given
      existing_property = @owner.properties.first
      existing_heir = @owner.heirs.first
      ETestament::PropertyHeir.where(property_id: existing_property[:id]).delete

      # when
      post "api/v1/properties/#{existing_property[:id]}/heirs/#{existing_heir[:id]}", { percentage: 5 }.to_json,
           @req_header

      # then
      ETestament::PropertyHeir.where(property_id: existing_property[:id]).first
      _(last_response.status).must_equal 200
    end

    it 'BAD AUTHORIZATION: should not be able to associate heirs with properties from other account' do
      # given
      existing_property = @owner.properties.first
      existing_heir = @owner.heirs.first
      ETestament::PropertyHeir.where(property_id: existing_property[:id]).delete

      login_account(@other_account_data)

      # when
      post "api/v1/properties/#{existing_property[:id]}/heirs/#{existing_heir[:id]}", { percentage: 40 }.to_json,
           @req_header

      # then
      ETestament::PropertyHeir.where(property_id: existing_property[:id]).first
      _(last_response.status).must_equal 403
    end

    it 'HAPPY: should be able to update heirs associated with a property' do
      # given
      existing_property = @owner.properties.first
      existing_heir = @owner.heirs.first

      # when
      post "api/v1/properties/#{existing_property[:id]}/heirs/#{existing_heir[:id]}/update", { percentage: 10 }.to_json,
           @req_header

      # then
      _(last_response.status).must_equal 200
      assert_equal 10, ETestament::PropertyHeir.where(property_id: existing_property[:id], heir_id: existing_heir[:id]).first.percentage
    end

    it 'HAPPY: should be able to dissociate an heir from a property' do
      # given
      existing_property = @owner.properties.first
      existing_heir = @owner.heirs.first

      # when
      post "api/v1/properties/#{existing_property[:id]}/heirs/#{existing_heir[:id]}/delete",
           @req_header

      # then
      _(last_response.status).must_equal 200
      assert_nil ETestament::PropertyHeir.first(property_id: existing_property[:id], heir_id: existing_heir[:id])
    end
  end
end

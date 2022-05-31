# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Heir Handling' do
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

  describe 'GET api/v1/heirs' do
    it 'HAPPY: should be able to get list of all heirs' do
      # when
      get 'api/v1/heirs'

      # then
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['data'].count).must_equal 1
    end
  end

  describe 'GET api/v1/heirs/:heir_id' do
    it 'HAPPY: should be able to get details of a single heir' do
      # given
      existing_heir = @owner.heirs.first

      # when
      get "/api/v1/heirs/#{existing_heir.id}"

      # then
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['data']['attributes']['id']).must_equal existing_heir.id
      _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
    end

    it 'HAPPY: should be able to get details of a single heir with executor account' do
      # given
      existing_heir = @owner.heirs.first

      # when
      get "/api/v1/heirs/#{existing_heir.id}"

      # then
      _(last_response.status).must_equal 200

      # when
      login_account(@executor_account_data)
      get "/api/v1/heirs/#{existing_heir.id}"

      # then
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal existing_heir.id
      _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
    end

    it 'BAD: should be able to get details of a single heir' do
      # given
      existing_heir = @owner.heirs.first

      # when
      login_account(@other_account_data)
      get "/api/v1/heirs/#{existing_heir.id}"

      # then
      _(last_response.status).must_equal 403
    end

    it 'SAD: should fail when fetching a nonexistent heir or invalid id' do
      # when
      get '/api/v1/heirs/69420'

      # then
      _(last_response.status).must_equal 404
    end
  end

  describe 'POST api/v1/heirs' do
    it 'HAPPY: should be able to create a heir' do
      # given
      new_heir = DATA[:heirs][0]
      new_heir['email'] = 'new_email@gmail.com'

      # when then
      assert_nil ETestament::Heir.first(email: new_heir['email'])

      # when
      post 'api/v1/heirs', new_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 201

      # when
      actual_heir = ETestament::Heir.first(account_id: @auth[:attributes][:account].id, email: new_heir['email'])
      _(actual_heir).wont_be_nil
    end

    it 'HAPPY: should be able to create an exising heir in another account' do
      # given
      new_heir = DATA[:heirs][0]
      new_heir['email'] = 'new_emai@gmail.com'

      # when
      post 'api/v1/heirs', new_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 201

      # when
      login_account(@executor_account_data)
      post 'api/v1/heirs', new_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 201
    end

    it 'BAD: should not be able to add a heir with existing heir email' do
      # given
      new_heir = DATA[:heirs][0]

      # when then
      _(ETestament::Heir.first(email: new_heir['email'])).wont_be_nil

      # when
      post 'api/v1/heirs', new_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 400
    end
  end

  describe 'POST api/v1/heirs/:heir_id' do
    it 'HAPPY: should be able to update a heir' do
      # given
      updated_heir = DATA[:heirs][0]
      existing_heir = ETestament::Heir.first(email: updated_heir['email'])

      updated_heir['email'] = 'updated_email@gmail.com'
      updated_heir['first_name'] = 'updated_email@gmail.com'
      updated_heir['last_name'] = 'updated_email@gmail.com'

      # when
      post "api/v1/heirs/#{existing_heir[:id]}", updated_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 200
    end

    it 'BAD: should not be able to update a heir with other account' do
      # given
      login_account(@executor_account_data)

      updated_heir = DATA[:heirs][0]
      existing_heir = ETestament::Heir.first(email: updated_heir['email'])

      updated_heir['email'] = 'updated_email@gmail.com'
      updated_heir['first_name'] = 'updated_email@gmail.com'
      updated_heir['last_name'] = 'updated_email@gmail.com'

      # when
      post "api/v1/heirs/#{existing_heir[:id]}", updated_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 403
    end

    it 'BAD: should not be able to update existing email' do
      # given
      dummy_heir = DATA[:heirs][1]
      post 'api/v1/heirs', dummy_heir.to_json, @req_header

      updated_heir = DATA[:heirs][0]
      target_heir = ETestament::Heir.first(email: updated_heir['email'])

      updated_heir['email'] = dummy_heir['email']

      # when
      post "api/v1/heirs/#{target_heir[:id]}", updated_heir.to_json, @req_header

      # then
      _(last_response.status).must_equal 400
    end
  end

  describe 'POST api/v1/heirs/:heir_id/delete' do
    it 'HAPPY: should be able delete a heir' do
      # given
      exiting_heir = ETestament::Heir.first

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/delete"

      # then
      _(last_response.status).must_equal 200
    end

    it 'BAD: should not be able delete a heir with other account' do
      # given
      login_account(@executor_account_data)
      exiting_heir = ETestament::Heir.first

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/delete"

      # then
      _(last_response.status).must_equal 403
    end
  end

  describe 'GET api/v1/heirs/:heir_id/properties' do
    it 'HAPPY: should be able to get properties by heir id' do
      # given
      exiting_heir = @owner.heirs.first

      # when
      get "api/v1/heirs/#{exiting_heir[:id]}/properties"

      # then
      _(last_response.status).must_equal 200
      _(JSON.parse(last_response.body).length).must_equal 1
    end

    # TODO: This should be with a different rout, not the one that pulls the heirs of the main account
    # it 'HAPPY: should be able to get properties by heir id' do
    #   # given
    #   exiting_heir = @owner.heirs.first
    #   login_account(@executor_account_data)

    #   # when
    #   get "api/v1/heirs/#{exiting_heir[:id]}/properties"

    #   # then
    #   _(last_response.status).must_equal 200
    #   _(JSON.parse(last_response.body).length).must_equal 1
    # end

    it 'BAD: should not be able to get properties by heir id from other account' do
      # given
      exiting_heir = @owner.heirs.first
      ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first
      exiting_heir[:id]
      login_account(@other_account_data)

      # when
      get "api/v1/heirs/#{exiting_heir[:id]}/properties"

      # then
      _(last_response.status).must_equal 403
    end
  end

  # describe 'GET api/v1/heirs/:heir_id/properties/:property_id' do
  #   # ?I Don't think we need this test, method already deleted
  #   it 'HAPPY: should be able to get properties' do
  #     # given
  #     exiting_heir = @owner.heirs.first
  #     associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property

  #     # when
  #     get "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}"

  #     # then
  #     _(last_response.status).must_equal 200
  #     result = JSON.parse(last_response.body)['data']['data']['attributes']
  #     _(result['account_id']).must_equal associated_property.account_id
  #     _(result['id']).must_equal associated_property.id
  #     _(result['property_type_id']).must_equal associated_property.property_type_id
  #     _(result['name']).must_equal associated_property.name
  #     _(result['description']).must_equal associated_property.description
  #   end

  #   # ?I Don't think we need this test, method already deleted
  #   it 'HAPPY: should be able to get properties by executor' do
  #     # given
  #     exiting_heir = @owner.heirs.first
  #     associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property
  #     # when
  #     login_account(@executor_account_data)
  #     get "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}"

  #     # then
  #     _(last_response.status).must_equal 200
  #     result = JSON.parse(last_response.body)['data']['data']['attributes']
  #     _(result['account_id']).must_equal associated_property.account_id
  #     _(result['id']).must_equal associated_property.id
  #     _(result['property_type_id']).must_equal associated_property.property_type_id
  #     _(result['name']).must_equal associated_property.name
  #     _(result['description']).must_equal associated_property.description
  #   end

  #   # ?I Don't think we need this test, method already deleted
  #   it 'BAD: should not be able to get properties by other' do
  #     exiting_heir = @owner.heirs.first
  #     associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property
  #     # when
  #     login_account(@other_account_data)
  #     get "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}"

  #     # then
  #     _(last_response.status).must_equal 403
  #   end
  # end

  describe 'POST api/v1/heirs/:heir_id/properties/:property_id :: Associate property and heir' do
    it 'HAPPY: should be able to associate property heir by owner' do
      # given
      property_type = ETestament::PropertyType.first
      existing_heir = @owner.heirs.first
      new_property = @owner.add_property(property_type_id: property_type[:id], name: 'new property',
                                         description: 'property description')
      percentage = 99.9

      # when
      post "api/v1/heirs/#{existing_heir[:id]}/properties/#{new_property[:id]}", { percentage: }.to_json, @req_header

      #  then
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)['data']['data']['attributes']
      _(result['heir_id']).must_equal existing_heir[:id]
      _(result['property_id']).must_equal new_property[:id]
      _(('%.10f' % result['percentage']).to_f).must_equal percentage
    end

    it 'BAD: should not be able to associate property heir by executor' do
      # given
      property_type = ETestament::PropertyType.first
      existing_heir = @owner.heirs.first
      new_property = @owner.add_property(property_type_id: property_type[:id], name: 'new property',
                                         description: 'property description')
      percentage = 99.9
      login_account(@executor_account_data)

      # when
      post "api/v1/heirs/#{existing_heir[:id]}/properties/#{new_property[:id]}", { percentage: }.to_json, @req_header

      #  then
      _(last_response.status).must_equal 403
    end

    it 'BAD: should not be able to associate property heir by other' do
      # given
      property_type = ETestament::PropertyType.first
      existing_heir = @owner.heirs.first
      new_property = @owner.add_property(property_type_id: property_type[:id], name: 'new property',
                                         description: 'property description')
      percentage = 99.9
      login_account(@other_account_data)

      # when
      post "api/v1/heirs/#{existing_heir[:id]}/properties/#{new_property[:id]}", { percentage: }.to_json, @req_header

      #  then
      _(last_response.status).must_equal 403
    end
  end

  describe 'POST api/v1/heirs/:heir_id/properties/:property_id/delete :: Disassociate property from heir' do
    it 'HAPPY: should be able to get properties by owner' do
      # given
      exiting_heir = @owner.heirs.first
      associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}/delete"

      # then
      _(last_response.status).must_equal 200
      assert_nil ETestament::PropertyHeir.where(property_id: associated_property[:id]).first
      _(ETestament::Property.where(id: associated_property[:id]).first).wont_be_nil
    end

    it 'BAD: should not be able to get properties by executor' do
      # given
      exiting_heir = @owner.heirs.first
      associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property
      login_account(@executor_account_data)

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}/delete"

      # then
      _(last_response.status).must_equal 403
    end

    it 'BAD: should not be able to get properties by other' do
      # given
      exiting_heir = @owner.heirs.first
      associated_property = ETestament::PropertyHeir.where(heir_id: exiting_heir[:id]).first.property
      login_account(@other_account_data)

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/properties/#{associated_property[:id]}/delete"

      # then
      _(last_response.status).must_equal 403
    end
  end
end

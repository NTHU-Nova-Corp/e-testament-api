# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Heir Handling' do
  include Rack::Test::Methods

  before(:each) do
    wipe_database
    seed_accounts
    seed_properties
    seed_heirs
    seed_property_heirs

    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    @account_data = DATA[:accounts][0]
    @auth = ETestament::Services::Accounts::Authenticate.call(
      username: @account_data['username'],
      password: @account_data['password']
    )
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
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
      account = ETestament::Account.first
      existing_heir = account.heirs.first

      # when
      get "/api/v1/heirs/#{existing_heir.id}"

      # then
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['data']['attributes']['id']).must_equal existing_heir.id
      _(result['data']['attributes']['first_name']).must_equal existing_heir.first_name
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
      _(ETestament::Heir.first(email: new_heir['email'])).must_be_nil

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
      @account_data = DATA[:accounts][1]
      @auth = ETestament::Services::Accounts::Authenticate.call(
        username: @account_data['username'],
        password: @account_data['password']
      )
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
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
    it 'should be able to update a heir' do
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

    it 'should not be able to update existing email' do
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
    it 'should be able delete a heir' do
      # given
      exiting_heir = ETestament::Heir.first

      # when
      post "api/v1/heirs/#{exiting_heir[:id]}/delete"

      # then
      _(last_response.status).must_equal 200
    end
  end

  describe 'GET api/v1/heirs/:heir_id/properties' do
    it 'should be able to get properties by heir id' do
      exiting_heir = ETestament::Heir.first

      get "api/v1/heirs/#{exiting_heir[:id]}/properties"

      _(last_response.status).must_equal 200
      _(JSON.parse(last_response.body).length).must_equal 1
    end
  end

  describe 'GET api/v1/heirs/[heir_id]/properties/:property_id' do
    #  TODO:
  end

  describe 'POST api/v1/heirs/[heir_id]/properties/:property_id' do
    #  TODO:
  end

  describe 'POST api/v1/heirs/[heir_id]/properties/:property_id/delete' do
    #  TODO:
  end
end

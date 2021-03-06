# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
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

  it 'HAPPY: should be able to get list of all documents related with a property' do
    property = @owner.properties.first

    # Create documents and tie them to the property
    DATA[:documents].each do |document|
      property.add_document(document)
    end

    get "api/v1/properties/#{property.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].size).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single document related with a property' do
    # document_data = ETestament::Document.create(DATA[:documents][1]).save
    property = @owner.properties.first
    test_doc = property.add_document(DATA[:documents][1])

    get "api/v1/properties/#{property.id}/documents/#{test_doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal test_doc.id
    _(result['data']['attributes']['property_id']).must_equal property.id
  end

  it 'SAD AUTHORIZATION: should return 404 if unknown document is requested' do
    properties = ETestament::Property.all.cycle

    property = properties.next
    document = property.add_document(DATA[:documents][0])

    property2 = properties.next
    document2 = property2.add_document(DATA[:documents][1])

    get "api/v1/properties/#{property.id}/documents/#{document.id}"
    _(last_response.status).must_equal 200

    get "api/v1/properties/#{property.id}/documents/#{document2.id}"
    _(last_response.status).must_equal 404
  end

  it 'BAD SQL_INJECTION: should prevent basic SQL injection targeting IDs' do
    property = ETestament::Property.first
    new_document = DATA[:documents][0]
    new_document2 = DATA[:documents][1]

    post "/api/v1/properties/#{property.id}/documents", new_document.to_json, @req_header
    post "/api/v1/properties/#{property.id}/documents", new_document2.to_json,
         @req_header

    get "api/v1/properties/#{property.id}/documents/2%20or%20TRUE"

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    assert_nil last_response.body['data']
  end

  it 'HAPPY: should be able to create new documents' do
    property = @owner.properties.first
    new_document = DATA[:documents][0]

    post "/api/v1/properties/#{property.id}/documents", new_document.to_json, @req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['attributes']
    document = ETestament::Document.where(property_id: ETestament::Property.first.id).first

    # _(created['id']).is_a(Integer)
    _(created['id']).must_equal document.id
    _(created['file_name']).must_equal new_document['file_name']
  end

  it 'HAPPY: should be able to delete existing document' do
    property = ETestament::Property.first
    document = property.add_document(DATA[:documents][0])

    id = document.id

    get "/api/v1/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 200

    post "/api/v1/properties/#{property.id}/documents/#{id}/delete"
    _(last_response.status).must_equal 200

    get "/api/v1/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 404
  end

  it 'SAD: should return 404 when try to delete a document that doesn\'t exist' do
    property = ETestament::Property.first

    delete "/api/v1/properties/#{property.id}/documents/69420/delete"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to update existing document' do
    # Set up properties and documents
    property = ETestament::Property.first
    document = property.add_document(DATA[:documents][0])
    id = document.id

    # Update parameters
    update_request = {}
    update_request[:file_name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Fetch document before update
    get "/api/v1/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 200
    result = JSON.parse(last_response.body)['data']['attributes']
    _(result['file_name']).wont_equal update_request[:file_name]
    _(result['description']).wont_equal update_request[:description]

    # Update the document
    post "/api/v1/properties/#{property.id}/documents/#{id}", update_request.to_json,
         @req_header
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']
    _(updated['file_name']).must_equal update_request[:file_name]
    _(updated['description']).must_equal update_request[:description]

    # Fetch document after update
    get "/api/v1/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']['attributes']
    _(updated['file_name']).must_equal update_request[:file_name]
    _(updated['description']).must_equal update_request[:description]
  end

  it 'SAD: should return 404 when try to update a document that doesn\'t exist' do
    # Set up properties and documents
    property = ETestament::Property.first

    # Update parameters
    update_request = {}
    update_request[:file_name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Try to update nonexistent document
    post "/api/v1/properties/#{property.id}/documents/111c1a38-3477-480f-9f04-9e510e43a864",
         update_request.to_json, @req_header
    _(last_response.status).must_equal 404
  end

  it 'BAD MASS_ASSIGNMENT:: should prevent edits to unauthorized fields' do
    # Set up properties and documents
    property = ETestament::Property.first
    request = DATA[:documents][0]
    data = property.add_document(request).save
    id = data.id

    # Update parameters
    update_request = {}
    update_request[:file_name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Hacker wants to commemorate the Xinhai Revolution :)
    update_request[:created_at] = '1911-10-10'

    # Try to update document with unauthorized field
    post "/api/v1/properties/#{property.id}/documents/#{id}", update_request.to_json,
         @req_header
    _(last_response.status).must_equal 400
  end
end

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    seed_accounts

    # Create properties with which documents will interact
    DATA[:properties].each do |property_data|
      account = ETestament::Account.first
      account.add_property(property_data).save
    end
  end

  it 'HAPPY: should be able to get list of all documents related with a property' do
    property = ETestament::Property.first

    # Create documents and tie them to the property
    DATA[:documents].each do |document|
      property.add_document(ETestament::Document.create(document).save)
    end

    get "api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.size).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single document related with a property' do
    # document_data = ETestament::Document.create(DATA[:documents][1]).save
    property = ETestament::Property.first
    test_doc = property.add_document(DATA[:documents][1])

    get "api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{test_doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal test_doc.id
    _(result['included']['property']['data']['attributes']['id']).must_equal property.id
  end

  it 'SAD: should return 404 if unknown document is requested or is not related with the property indicated' do
    ETestament::Document.create(DATA[:documents][1]).save
    actual_test_doc = ETestament::Document.create(DATA[:documents][2]).save
    property = ETestament::Property.first

    get "api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{actual_test_doc.id}"
    _(last_response.status).must_equal 404

    get "api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/69420"
    _(last_response.status).must_equal 404
  end

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    property = ETestament::Property.first
    new_document = DATA[:documents][0]
    new_document2 = DATA[:documents][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents", new_document.to_json, req_header
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents", new_document2.to_json,
         req_header

    get "api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/2%20or%20TRUE"

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  it 'HAPPY: should be able to create new documents' do
    property = ETestament::Property.first
    new_document = DATA[:documents][0]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents", new_document.to_json, req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    document = ETestament::Document.where(property_id: ETestament::Property.first.id).first

    # _(created['id']).is_a(Integer)
    _(created['id']).must_equal document.id
    _(created['file_name']).must_equal new_document['file_name']
    _(created['relative_path']).must_equal new_document['relative_path']
  end

  it 'HAPPY: should be able to delete existing document' do
    property = ETestament::Property.first
    document = ETestament::Document.create(DATA[:documents][0]).save
    property.add_document(document)

    id = document.id

    get "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 200

    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}/delete"
    _(last_response.status).must_equal 200

    get "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 404
  end

  it 'SAD: should return 404 when try to delete a document that doesn\'t exist' do
    property = ETestament::Property.first

    delete "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/69420/delete"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to update existing document' do
    # Set up properties and documents
    property = ETestament::Property.first
    request = DATA[:documents][0]
    data = ETestament::Document.create(request).save
    property.add_document(data)
    id = data.id

    # Update parameters
    update_request = {}
    update_request[:file_name] = 'Test update_name'
    update_request[:description] = 'Test description'

    # Fetch document before update
    get "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}"
    _(last_response.status).must_equal 200
    result = JSON.parse(last_response.body)['data']['attributes']
    _(result['file_name']).wont_equal update_request[:file_name]
    _(result['description']).wont_equal update_request[:description]

    # Update the document
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}", update_request.to_json,
         req_header
    _(last_response.status).must_equal 200
    updated = JSON.parse(last_response.body)['data']
    _(updated['file_name']).must_equal update_request[:file_name]
    _(updated['description']).must_equal update_request[:description]

    # Fetch document after update
    get "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}"
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
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/111c1a38-3477-480f-9f04-9e510e43a864",
         update_request.to_json, req_header
    _(last_response.status).must_equal 404
  end

  it 'SAD: should prevent edits to unauthorized fields' do
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
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/accounts/#{property.account_id}/properties/#{property.id}/documents/#{id}", update_request.to_json,
         req_header
    _(last_response.status).must_equal 400
  end
end

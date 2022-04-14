# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:properties].each do |property_data|
      ETestament::Property.create(property_data)
    end
  end

  it 'HAPPY: should be able to get list of all documents related with a property' do
    property = ETestament::Property.first

    DATA[:documents].each do |document|
      property.add_document(document)
    end

    get "api/v1/properties/#{property.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.size).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single document related with a property' do
    document_data = DATA[:documents][1]
    property = ETestament::Property.first
    test_doc = property.add_document(document_data).save

    get "api/v1/properties/#{property.id}/documents/#{test_doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal test_doc.id
    _(result['data']['attributes']['property_id']).must_equal property.id
  end

  it 'SAD: should return 404 if document requested is not related with the property indicated' do
    
  end

  it 'HAPPY: should be able to create new documents' do
    
  end

  it 'HAPPY: should be able to delete existing document' do
    
  end

  it 'SAD: should return 404 when try to delete a document that doesnt exists' do
    
  end

  it 'HAPPY: should be able to update existing document' do
    
  end

  it 'SAD: should return 404 when try to update a document that doesnt exists' do
    
  end
end

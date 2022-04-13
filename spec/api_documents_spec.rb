# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all documents related with a property' do
    property_info = ETestament::Property.create(DATA[:properties][0]).values
    property_id = property_info[:id]

    doc1 = DATA[:documents][0]
    doc1['property_id'] = property_id
    ETestament::Document.create(doc1).values

    doc2 = DATA[:documents][1]
    doc2['property_id'] = property_id
    ETestament::Document.create(doc2).values

    doc3 = DATA[:documents][2]
    doc3['property_id'] = property_id
    ETestament::Document.create(doc3).values

    get "api/v1/properties/#{property_id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.size).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single document related with a property' do
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

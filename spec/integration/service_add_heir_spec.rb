# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddHeirToProperty service' do
  before do
    wipe_database

    #   DATA[:accounts].each do |account_data|
    #     ETestament::Account.create(account_data)
    #   end

    #   property_data = DATA[:properties].first

    #   @owner = ETestament::Account.first()
    #   @heir = ETestament::Heir.first()
    #   @project = ETestament::CreatePropertyForAccount.call(
    #     account_id: @owner.id, property:
    #   )
    # end

    # it 'HAPPY: should be able to add a heir to a property' do
    #   ETestament::AddHeirToProperty.call(
    #     email: @collaborator.email,
    #     project_id: @project.id
    #   )

    #   _(@collaborator.properties.count).must_equal 1
    #   _(@collaborator.properties.first).must_equal @project
    # end

    # it 'BAD: should not add owner as a collaborator' do
    #   _(proc {
    #     ETestament::AddHeirToProperty.call(
    #       email: @owner.email,
    #       project_id: @project.id
    #     )
    #   }).must_raise ETestament::AddCollaboratorToProject::OwnerNotCollaboratorError
  end
end

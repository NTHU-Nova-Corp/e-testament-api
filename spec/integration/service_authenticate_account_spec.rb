# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authenticate service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      ETestament::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = ETestament::Services::Accounts::Authenticate.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      ETestament::Services::Accounts::Authenticate.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise ETestament::Exceptions::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      ETestament::Services::Accounts::Authenticate.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise ETestament::Exceptions::UnauthorizedError
  end
end

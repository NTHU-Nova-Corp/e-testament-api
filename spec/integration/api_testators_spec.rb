# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Testators Handling' do
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
    seed_heirs

    # setup data
    @executor_data = DATA[:accounts][0]
    @testator_data = DATA[:accounts][1]

    # setup account
    @accounts = ETestament::Account.all.cycle
    @executor = @accounts.next
    @testator = @accounts.next

    # setup login account
    login_account(@executor_data)
  end

  describe 'Testators information' do
    before(:each) do
      assign_executors
    end
    describe 'GET /api/v1/testators :: testators of an executor' do
      it 'HAPPY: should be able to get testators' do
        # when
        get '/api/v1/testators'

        # then
        _(last_response.status).must_equal 200
        data = JSON.parse(last_response.body)['data']
        _(data.length).must_equal 2

        attributes = data[0]['attributes']
        _(attributes['id']).must_equal @testator[:id]
        _(attributes['username']).must_equal @testator[:username]
        _(attributes['first_name']).must_equal @testator[:first_name]
        _(attributes['last_name']).must_equal @testator[:last_name]
        _(attributes['email']).must_equal @testator[:email]
      end
    end

    describe 'GET /api/v1/testators/:testator_id :: testator information' do
      it 'HAPPY: should be able to get testator information' do
        # when
        get "/api/v1/testators/#{@testator[:id]}"

        # then
        _(last_response.status).must_equal 200
        attributes = JSON.parse(last_response.body)['data']['attributes']
        _(attributes['id']).must_equal @testator[:id]
        _(attributes['username']).must_equal @testator[:username]
        _(attributes['first_name']).must_equal @testator[:first_name]
        _(attributes['last_name']).must_equal @testator[:last_name]
        _(attributes['email']).must_equal @testator[:email]
      end
    end

    describe 'GET /api/v1/testator/:testator_id/heirs :: heirs of a testator' do
      it 'HAPPY: should be able to get heirs details of a testator' do
        # when
        get "/api/v1/testators/#{@testator[:id]}/heirs"

        # then
        _(last_response.status).must_equal 200

        data = JSON.parse(last_response.body)['data']
        attributes = data[0]['attributes']

        _(attributes['first_name']).wont_be_nil
        _(attributes['last_name']).wont_be_nil
        _(attributes['email']).wont_be_nil
        _(attributes['relation']).wont_be_nil
      end

      it 'BAD AUTHORIZATION: should not be able to get details of heir list from other executor' do
        login_account(@testator_data)

        get "/api/v1/testators/#{@executor[:id]}/heirs"

        _(last_response.status).must_equal 403
      end
    end

    describe 'POST api/v1/testators/:testator_id/read :: read testament of a testator' do
      it 'SAD: should not be able to read testament with non-existing id' do
        # when
        post "/api/v1/testators/#{@testator[:id]}-wrong/read"

        # then
        _(last_response.status).must_equal 400
        _(JSON.parse(last_response.body)['message']).must_equal 'No testator found'
      end

      it 'SAD: should not be able to read testament when min amount heir is invalid' do
        # given
        @testator.update(min_amount_heirs: 1).save

        # when
        post "/api/v1/testators/#{@testator[:id]}/read"

        # then
        _(last_response.status).must_equal 400
        _(JSON.parse(last_response.body)['message']).must_equal 'There are not enough keys to release the testament'
      end

      it 'SAD: should be not able to read testament if combined keys are wrong' do
        # given
        # combined_key & shared keys
        min_amount_heirs = 2
        extend Securable
        combined_key = generate_key
        shamir = ShamirEncryption::ShamirSecretSharing
        shares = shamir::Base64.split(combined_key, 2, min_amount_heirs)

        # set up account
        ETestament::Heir.map(&:destroy)
        @testator.add_heir(DATA[:heirs][1])
        @testator.add_heir(DATA[:heirs][2])
        @testator.update(min_amount_heirs:).save
        @testator.update(combined_key:).save
        heirs = @testator.heirs.cycle
        heirs.next.update(key_content_submitted: "12323#{shares[0]}").save
        heirs.next.update(key_content_submitted: shares[1]).save

        # when
        post "/api/v1/testators/#{@testator[:id]}/read"

        # then
        _(last_response.status).must_equal 500
      end
      it 'SAD: should be not able to read testament if the status is not released' do
        # given
        # combined_key & shared keys
        min_amount_heirs = 2
        extend Securable
        combined_key = generate_key
        shamir = ShamirEncryption::ShamirSecretSharing
        shares = shamir::Base64.split(combined_key, 2, min_amount_heirs)

        # set up account
        ETestament::Heir.map(&:destroy)
        @testator.add_heir(DATA[:heirs][1])
        @testator.add_heir(DATA[:heirs][2])
        @testator.update(min_amount_heirs:).save
        @testator.update(combined_key:).save
        heirs = @testator.heirs.cycle
        heirs.next.update(key_content_submitted: shares[0]).save
        heirs.next.update(key_content_submitted: shares[1]).save

        # when
        post "/api/v1/testators/#{@testator[:id]}/read"

        # then
        _(last_response.status).must_equal 400
        _(JSON.parse(last_response.body)['message']).must_equal 'You are not allowed to read this testament'
      end

      it 'SAD: should be not able to read testament if reader is not executor of testator' do
        # given
        # combined_key & shared keys
        min_amount_heirs = 2
        extend Securable
        combined_key = generate_key
        testament_status = 'Released'
        shamir = ShamirEncryption::ShamirSecretSharing
        shares = shamir::Base64.split(combined_key, 2, min_amount_heirs)

        # set up account
        ETestament::Heir.map(&:destroy)
        @testator.add_heir(DATA[:heirs][1])
        @testator.add_heir(DATA[:heirs][2])
        @testator.update(min_amount_heirs:).save
        @testator.update(testament_status:).save
        @testator.update(combined_key:).save
        heirs = @testator.heirs.cycle
        heirs.next.update(key_content_submitted: shares[0]).save
        heirs.next.update(key_content_submitted: shares[1]).save

        # when
        post "/api/v1/testators/#{@testator[:id]}/read"

        # then
        _(last_response.status).must_equal 400
        _(JSON.parse(last_response.body)['message']).must_equal 'You are not allowed to read this testament'
      end

      it 'HAPPY: should be able to read testament if the status is released' do
        # given
        # combined_key & shared keys
        min_amount_heirs = 2
        extend Securable
        combined_key = generate_key
        testament_status = 'Released'
        shamir = ShamirEncryption::ShamirSecretSharing
        shares = shamir::Base64.split(combined_key, 2, min_amount_heirs)

        # set up account
        ETestament::Heir.map(&:destroy)
        @testator.add_heir(DATA[:heirs][1])
        @testator.add_heir(DATA[:heirs][2])
        @testator.update(executor_id: @executor[:id])
        @testator.update(min_amount_heirs:).save
        @testator.update(testament_status:).save
        @testator.update(combined_key:).save
        heirs = @testator.heirs.cycle
        heirs.next.update(key_content_submitted: shares[0]).save
        heirs.next.update(key_content_submitted: shares[1]).save

        # when
        post "/api/v1/testators/#{@testator[:id]}/read"

        # then
        _(last_response.status).must_equal 200
      end
    end
  end

  describe 'Executor request flow' do
    before(:each) do
      assert_nil ETestament::PendingExecutorAccount.first(executor_email: @executor[:email])

      login_account(@testator_data)
      post 'api/v1/executors', { email: @executor[:email] }.to_json, @req_header
    end

    describe 'GET api/v1/testators/request' do
      it 'HAPPY: should be able to get testator request list' do
        # given
        login_account(@executor_data)

        # when
        get 'api/v1/testators/request'

        # then
        _(last_response.status).must_equal 200
        attributes = JSON.parse(last_response.body)['data']['attributes']

        _(attributes['id']).must_equal @testator[:id]
        _(attributes['username']).must_equal @testator[:username]
        _(attributes['first_name']).must_equal @testator[:first_name]
        _(attributes['last_name']).must_equal @testator[:last_name]
        _(attributes['email']).must_equal @testator[:email]
      end
    end

    describe 'POST api/v1/testators/:testator_id/accept' do
      it 'HAPPY: should be able to accept' do
        # given
        login_account(@executor_data)

        # when then
        assert_nil @testator[:executor_id]
        _(ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])).wont_be_nil

        # when then
        post "api/v1/testators/#{@testator[:id]}/accept"
        _(last_response.status).must_equal 200

        testator = ETestament::Account.first(email: @testator[:email])
        _(testator[:executor_id]).must_equal @executor[:id]
        assert_nil ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])
      end
    end

    describe 'POST api/v1/testators/:testator_id/reject' do
      it 'HAPPY: should be able to reject' do
        # given
        login_account(@executor_data)

        # pre-verify
        assert_nil @testator[:executor_id]
        _(ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])).wont_be_nil

        # when
        post "api/v1/testators/#{@testator[:id]}/reject"

        # then
        _(last_response.status).must_equal 200
        assert_nil @testator[:executor_id]
        assert_nil ETestament::PendingExecutorAccount.first(executor_account_id: @executor[:id])
      end
    end

    describe 'POST api/v1/testators/:testator_id/release' do
      before(:each) do
        # clear
        wipe_database

        # seed
        seed_accounts
        seed_properties
        seed_heirs
        seed_property_heirs

        @testator_data = DATA[:accounts][0]
        @executor_data = DATA[:accounts][1]
        @accounts = ETestament::Account.all.cycle
        @testator = @accounts.next
        @executor = @accounts.next

        @testator.properties.map do |property|
          property.property_heirs.map do |property_heir|
            property_heir.update(percentage: 100).save
          end
        end

        # testator complete testament
        login_account(@testator_data)
        post 'api/v1/testaments/complete', { min_amount_heirs: 2 }.to_json, @req_header
        _(last_response.status).must_equal 200

        # testator request executor
        post 'api/v1/executors', { email: @executor[:email] }.to_json, @req_header
        _(last_response.status).must_equal 200

        # executor accept request
        login_account(@executor_data)
        post "api/v1/testators/#{@testator[:id]}/accept"
        _(last_response.status).must_equal 200

        @testator.refresh
        @executor.refresh
      end

      it 'HAPPY: executor should be able to release the testament' do
        # given
        login_account(@executor_data)

        # when
        post "api/v1/testators/#{@testator[:id]}/release", @req_header
        _(last_response.status).must_equal 200
      end
    end
  end
end

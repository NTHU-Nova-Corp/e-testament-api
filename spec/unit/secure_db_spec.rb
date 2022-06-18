# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test SecureDB Class' do
  it 'HAPPY: should encrypt text' do
    test_data = 'test data'
    text_sec = SecureDB.encrypt(test_data)
    _(text_sec).wont_equal test_data
  end

  it 'HAPPY: should decrypt encrypted ASCII' do
    test_data = "test data ~ 1 & \n"
    text_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(text_sec)
    _(test_decrypted).must_equal test_data
  end

  it 'HAPPY: should decrypt non-ASCII characters' do
    test_data = '我的名字是吳心潼有時候是江詢但是我其實是希塞！'
    text_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(text_sec)
    _(test_decrypted).must_equal test_data
  end
end

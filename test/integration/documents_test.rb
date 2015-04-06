require 'test_helper'

class DocumentsTest < ActionDispatch::IntegrationTest
  test 'should get policy' do
    get '/policy'
    assert_response :success
  end

  test 'should get privacy' do
    get '/privacy'
    assert_response :success
  end

  test 'should get cookies' do
    get '/cookies'
    assert_response :success
  end

  test 'should get values' do
    get '/values'
    assert_response :success
  end

end

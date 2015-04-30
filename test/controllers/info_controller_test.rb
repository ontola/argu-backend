require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get show' do
    sign_in users(:user)

    get :show, {'id' => 'team'}

    assert_response 200
    assert assigns(:document)
    assert_equal 'block--full', assigns(:document)['sections'].first['type']
  end

  test 'should 404 for get nonexistent' do
    sign_in users(:user)

    get :show, {'id' => 'does_not_exist'}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-json setting' do
    sign_in users(:user)

    get :show, {'id' => 'error_quotes'}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-info setting' do
    sign_in users(:user)

    get :show, {'id' => 'non_info_json'}

    assert_response 404
    assert assigns(:document)
  end

end
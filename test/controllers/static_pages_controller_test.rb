require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get redirect' do
    sign_in users(:user)

    get :team

    assert_response 302
  end

  test 'should get how_argu_works' do
    sign_in users(:user)

    get :how_argu_works

    assert_response :success
  end

end
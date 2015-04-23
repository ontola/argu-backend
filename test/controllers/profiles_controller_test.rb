require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get edit profile with own profile' do
    sign_in users(:user)

    get :edit, id: users(:user).url

    assert_response 200
    assert_equal users(:user), assigns(:resource), ''
    assert_equal users(:user).profile, assigns(:profile), ''
  end

  test 'should not get edit profile with other profile' do
    sign_in users(:user)

    get :edit, id: users(:user_thom).url

    assert_response 302
    assert_equal users(:user_thom), assigns(:resource)
    assert_equal users(:user_thom).profile, assigns(:profile)
  end

  test 'should get edit profile when page owner' do
    sign_in users(:user_thom)

    get :edit, id: pages(:page_argu).url

    assert_response 200
    assert_equal pages(:page_argu), assigns(:resource)
    assert_equal pages(:page_argu).profile, assigns(:profile)
  end

  test 'should not get edit profile when not page owner' do
    sign_in users(:user)

    get :edit, id: pages(:page_argu).url

    assert_response 302
    assert_equal pages(:page_argu), assigns(:resource)
    assert_equal pages(:page_argu).profile, assigns(:profile)
  end

end

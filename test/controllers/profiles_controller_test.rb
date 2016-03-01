require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  ####################################
  # As User
  ####################################
  test 'user should get edit profile with own profile' do
    sign_in user

    get :edit, id: user.url

    assert_response 200
    assert_equal user, assigns(:resource), ''
    assert_equal user.profile, assigns(:profile), ''
  end

  test 'user should not get edit profile with other profile' do
    sign_in user

    get :edit, id: user2.url

    assert_response 302
    assert_equal user2, assigns(:resource)
    assert_equal user2.profile, assigns(:profile)
  end

end

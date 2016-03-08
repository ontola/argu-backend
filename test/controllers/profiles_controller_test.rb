require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ProfilesHelper

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:place) { FactoryGirl.create(:place) }

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

  test 'user should create place and placement on update' do
    sign_in user

    assert_differences [['Place.count', 1],['Placement.count', 1]] do
      put :update,
          id: user.url,
          profile: {
              postal_code: '3583GP',
              country: 'NL',
              profileable_attributes: { first_name: 'name' }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should not create place and placement on update with wrong postal code' do
    sign_in user

    assert_differences [['Place.count', 0],['Placement.count', 0]] do
      put :update,
          id: user.url,
          profile: {
              postal_code: 'wrong_postal_code',
              country: 'NL',
              profileable_attributes: { first_name: 'name' }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end

  test 'user should not create place but should create placement on update with cached postal code and country code' do
    sign_in user
    place

    assert_differences [['Place.count', 0],['Placement.count', 1]] do
      put :update,
          id: user.url,
          profile: {
              postal_code: '3583GP',
              country: 'NL',
              profileable_attributes: { first_name: 'name' }
          }
    end
    assert_redirected_to dual_profile_url(user.profile)
  end
end

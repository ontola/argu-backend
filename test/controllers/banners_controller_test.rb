require 'test_helper'

class BannersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { create(:populated_forum, name: 'holland') }
  let!(:holland_owner) { create(:user) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    banner_attributes = attributes_for(:banner)
    assert_no_difference('Banner.count') do
      post :create,
           forum_id: holland,
           banner: banner_attributes
      assert_redirected_to new_user_session_path(r: forum_banners_path(holland, banner: banner_attributes))
    end
  end

  ####################################
  # As User
  ####################################
  test 'user should not post create' do
    sign_in create(:user)

    assert_no_difference('Banner.count') do
      post :create,
           forum_id: holland,
           banner: attributes_for(:banner)
      assert_response 403
    end
  end

  ####################################
  # As Member
  ####################################
  test 'member should not post create' do
    sign_in create_member(holland)

    assert_no_difference('Banner.count') do
      post :create,
           forum_id: holland,
           banner: attributes_for(:banner)
      assert_redirected_to holland
    end
  end

  ####################################
  # As Manager
  ####################################
  test 'manager should post create' do
    sign_in create_manager(holland)

    assert_difference('Banner.count') do
      post :create,
           forum_id: holland,
           banner: attributes_for(:banner)
      assert_redirected_to settings_forum_path(holland, tab: :banners)
    end
  end

  ####################################
  # As Owner
  ####################################
  test 'owner should post create' do
    sign_in create_owner(holland, holland_owner)

    assert_difference('Banner.count') do
      post :create,
           forum_id: holland,
           banner: attributes_for(:banner)
      assert_redirected_to settings_forum_path(holland, tab: :banners)
    end
  end

end

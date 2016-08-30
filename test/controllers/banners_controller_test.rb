# frozen_string_literal: true
require 'test_helper'

class BannersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  let(:owner) { freetown.edge.parent.owner.owner.profileable }

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    banner_attributes = attributes_for(:banner)
    assert_no_difference('Banner.count') do
      post :create,
           forum_id: freetown,
           banner: banner_attributes
      assert_redirected_to new_user_session_path(r: forum_banners_path(freetown))
    end
  end

  ####################################
  # As User
  ####################################
  test 'user should not post create' do
    sign_in create(:user)

    assert_no_difference('Banner.count') do
      post :create,
           forum_id: freetown,
           banner: attributes_for(:banner)
      assert_response 403
    end
  end

  ####################################
  # As Member
  ####################################
  test 'member should not post create' do
    sign_in create_member(freetown)

    assert_no_difference('Banner.count') do
      post :create,
           forum_id: freetown,
           banner: attributes_for(:banner)
      assert_redirected_to freetown
    end
  end

  ####################################
  # As Manager
  ####################################
  test 'manager should post create' do
    sign_in create_manager(freetown)

    assert_difference('Banner.count') do
      post :create,
           forum_id: freetown,
           banner: attributes_for(:banner)
      assert_redirected_to settings_forum_path(freetown, tab: :banners)
    end
  end

  ####################################
  # As Owner
  ####################################
  test 'owner should post create' do
    sign_in create_owner(freetown, owner)

    assert_difference('Banner.count') do
      post :create,
           forum_id: freetown,
           banner: attributes_for(:banner)
      assert_redirected_to settings_forum_path(freetown, tab: :banners)
    end
  end
end

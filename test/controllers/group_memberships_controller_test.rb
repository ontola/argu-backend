# frozen_string_literal: true
require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown
  let!(:group) { create(:group, forum: freetown) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'should not show new' do
    sign_in user

    get :new, group_id: group

    assert_redirected_to forum_path(freetown)
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not post create' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: group, profile_id: user.profile
    end

    assert_redirected_to forum_path(freetown)
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not delete destroy' do
    sign_in user

    group_membership = create(:group_membership,
                              group: group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_redirected_to root_path
  end

  ####################################
  # As Owner
  ####################################

  test 'should show new' do
    sign_in create_owner(freetown)

    get :new, group_id: group

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
    assert assigns(:membership)
  end

  test 'owner should post create' do
    sign_in create_owner(freetown)

    assert_difference 'GroupMembership.count', 1 do
      post :create, group_id: group, profile_id: user.to_param
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
    assert assigns(:forum)
    assert assigns(:membership)
  end

  test 'owner should delete destroy' do
    sign_in create_owner(freetown)

    group_membership = create(:group_membership,
                              group: group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end
end

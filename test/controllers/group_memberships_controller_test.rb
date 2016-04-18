# frozen_string_literal: true
require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown
  define_cairo
  let!(:group) { create(:group, parent: freetown.edge) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'should not show new members_group' do
    sign_in user

    get :new, group_id: group

    assert_redirected_to forum_path(freetown)
  end

  test 'should not post create' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: group
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'should post create to open members_group' do
    sign_in user

    assert_difference('GroupMembership.count', 1) do
      post :create, group_id: freetown.members_group
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'should not post create to closed members_group' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: cairo.members_group
    end

    assert_redirected_to root_path
  end

  test 'should not delete destroy other membership' do
    sign_in user

    group_membership = create(:group_membership,
                              parent: group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_response 403
  end

  test 'should not delete destroy own membership' do
    sign_in user

    group_membership = create(:group_membership,
                              member: user.profile,
                              parent: group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_response 403
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not post create' do
    request.env['HTTP_REFERER'] = forum_path(freetown)
    sign_in member

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: freetown.members_group
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'member should not post create other to open members_group' do
    request.env['HTTP_REFERER'] = forum_path(freetown)
    sign_in member

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: freetown.members_group, shortname: user.url
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'member should delete destroy self from members_group' do
    sign_in member

    assert_difference('GroupMembership.count', -1) do
      delete :destroy, id: member.profile.memberships.first
    end

    assert_response 302
    assert_redirected_to forum_path(freetown)
  end

  test 'member should not delete destroy other from members_group' do
    sign_in member

    group_membership = create(:group_membership,
                              parent: freetown.members_group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_redirected_to forum_path(freetown)
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should show new' do
    sign_in create_owner(freetown)

    get :new, group_id: group

    assert_response 200
  end

  test 'owner should post create other' do
    sign_in create_owner(freetown)

    assert_difference 'GroupMembership.count', 1 do
      post :create,
           group_id: group,
           shortname: user.url,
           r: settings_forum_path(freetown.url, tab: :groups)
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end

  test 'owner should delete destroy' do
    sign_in create_owner(freetown)

    group_membership = create(:group_membership,
                              parent: group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership, r: settings_forum_path(freetown.url, tab: :groups)
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end
end

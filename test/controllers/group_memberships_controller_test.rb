# frozen_string_literal: true
require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  define_cairo
  let!(:group) { create(:group, parent: freetown.page.edge) }

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not show new members_group' do
    sign_in user

    get :new, params: {group_id: group}

    assert_not_authorized
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: group}
    end

    assert 404
  end

  test 'user should post create to open members_group' do
    sign_in user

    assert_differences([['GroupMembership.count', 1],
                        ['freetown.edge.followers.count', 1]]) do
      post :create, params: {group_id: freetown.members_group}
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'user should not post create to closed members_group' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: cairo.members_group}
    end

    assert 404
  end

  test 'user should not delete destroy other membership' do
    sign_in user

    group_membership = create(:group_membership,
                              parent: group.edge)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, params: {id: group_membership}
    end

    assert_not_authorized
  end

  test 'user should not delete destroy own membership' do
    sign_in user

    group_membership = create(:group_membership,
                              member: user.profile,
                              parent: group.edge)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, params: {id: group_membership}
    end

    assert_not_authorized
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not post create' do
    request.env['HTTP_REFERER'] = forum_path(freetown)
    sign_in member

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: freetown.members_group}
    end

    assert 404
  end

  test 'member should not post create other to open members_group' do
    request.env['HTTP_REFERER'] = forum_path(freetown)
    sign_in member

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: freetown.members_group, shortname: user.url}
    end

    assert 404
  end

  test 'member should delete destroy self from members_group' do
    sign_in member

    assert_difference('GroupMembership.count', -1) do
      delete :destroy, params: {id: member.profile.group_memberships.first}
    end

    assert_response 302
    assert_redirected_to forum_path(freetown)
  end

  test 'member should not delete destroy other from members_group' do
    sign_in member

    group_membership = create(:group_membership,
                              parent: freetown.members_group.edge)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, params: {id: group_membership}
    end

    assert_redirected_to forum_path(freetown)
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should show new' do
    sign_in create_owner(freetown)

    get :new, params: {group_id: group}

    assert_response 200
  end

  test 'owner should post create other' do
    sign_in create_owner(freetown)

    assert_difference 'GroupMembership.count', 1 do
      post :create,
           params: {
             group_id: group,
             shortname: user.url,
             r: settings_forum_path(freetown.url, tab: :groups)
           }
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end

  test 'owner should delete destroy' do
    sign_in create_owner(freetown)

    group_membership = create(:group_membership,
                              parent: group.edge)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy,
             params: {
               id: group_membership,
               r: settings_forum_path(freetown.url, tab: :groups)
             }
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end

  ####################################
  # As Page
  ####################################
  test 'page should post create other' do
    sign_in create_owner(freetown)
    change_actor freetown.page

    assert_difference 'GroupMembership.count', 1 do
      post :create,
           params: {
             group_id: group,
             shortname: user.url,
             r: settings_forum_path(freetown.url, tab: :groups)
           }
    end

    assert_redirected_to settings_forum_path(freetown.url, tab: :groups)
  end
end

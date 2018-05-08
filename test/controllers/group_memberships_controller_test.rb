# frozen_string_literal: true

require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  define_freetown
  define_freetown('freetown2')
  let!(:group) { create(:group, parent: freetown.page.edge) }
  let!(:forum_group) { create(:group, parent: freetown.page.edge) }
  let!(:single_forum_group) { create(:group, parent: freetown.page.edge) }
  let!(:page_group) { create(:group, parent: freetown.page.edge) }
  let!(:grant) { create(:grant, edge: freetown.edge, group: single_forum_group) }
  let!(:freetown_grant) { create(:grant, edge: freetown.edge, group: forum_group) }
  let!(:freetown2_grant) { create(:grant, edge: freetown2.edge, group: forum_group) }
  let!(:page_grant) { create(:grant, edge: argu.edge, group: page_group) }
  let!(:member) { create(:group_membership, parent: group).member.profileable }
  let(:single_forum_group_member) { create(:group_membership, parent: single_forum_group).member.profileable }

  ####################################
  # As User not accepted terms
  ####################################
  let(:user_not_accepted) { create(:user, :not_accepted_terms) }

  test 'user not accepted terms should post create with valid token for single_forum_group' do
    validate_valid_bearer_token
    sign_in user_not_accepted

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 1], ['Follow.count', 0]] do
      post :create, params: {group_id: single_forum_group, token: '1234567890'}
    end

    assert_redirected_to freetown.iri_path
  end

  test 'user not accepted terms should post create with valid token for forum_group' do
    validate_valid_bearer_token
    sign_in user_not_accepted

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 2], ['Follow.count', 0]] do
      post :create, params: {group_id: forum_group, token: '1234567890'}
    end

    assert_redirected_to argu.iri_path
  end

  test 'user not accepted terms should post create with valid token for page_group' do
    validate_valid_bearer_token
    sign_in user_not_accepted

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 2], ['Follow.count', 0]] do
      post :create, params: {group_id: page_group, token: '1234567890'}
    end

    assert_redirected_to argu.iri_path
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show' do
    sign_in user

    get :show, params: {id: member.profile.group_memberships.second}

    assert_not_authorized
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: group}
    end

    assert_not_authorized
  end

  test 'user should not post create with invalid token' do
    validate_invalid_bearer_token
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {group_id: group, token: '1234567890'}
    end

    assert_not_authorized
  end

  test 'user with group_memberships should not post create as json' do
    validate_valid_bearer_token
    sign_in user
    forum_edge_ids = single_forum_group.page.edge.children.where(owner_type: 'Forum').pluck(:id)
    forum_edge_ids.each do |forum_edge_id|
      Favorite.create!(user: user, edge_id: forum_edge_id)
    end
    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 0], ['Follow.count', 0]] do
      post :create, format: :json, params: {group_id: single_forum_group, token: '1234567890'}
    end
    assert_response :created
  end

  test 'user should post create with valid token for single_forum_group' do
    validate_valid_bearer_token
    sign_in user

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 1], ['Follow.count', 1]] do
      post :create, params: {group_id: single_forum_group, token: '1234567890'}
    end
    assert_equal user.reload.following_type(freetown.edge), 'news'

    assert_redirected_to freetown.iri_path
  end

  test 'user should post create with valid token for single_forum_group with never follow present' do
    validate_valid_bearer_token
    sign_in user

    create(:follow, followable: freetown.edge, follower: user, follow_type: 'never')
    assert_equal user.following_type(freetown.edge), 'never'

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 1], ['Follow.count', 0]] do
      post :create, params: {group_id: single_forum_group, token: '1234567890'}
    end
    assert_equal user.reload.following_type(freetown.edge), 'never'

    assert_redirected_to freetown.iri_path
  end

  test 'user should post create with valid token for forum_group' do
    validate_valid_bearer_token
    sign_in user

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 2], ['Follow.count', 2]] do
      post :create, params: {group_id: forum_group, token: '1234567890'}
    end

    assert_redirected_to argu.iri_path
  end

  test 'user should post create with valid token for page_group' do
    validate_valid_bearer_token
    sign_in user

    assert_differences [['GroupMembership.count', 1], ['Favorite.count', 2], ['Follow.count', 2]] do
      post :create, params: {group_id: page_group, token: '1234567890'}
    end

    assert_redirected_to argu.iri_path
  end

  ####################################
  # As Member
  ####################################
  test 'member should get show' do
    sign_in member

    get :show, params: {id: member.profile.group_memberships.second}

    assert_redirected_to freetown.page.iri_path
  end

  test 'member should get show with forum grant' do
    sign_in member
    create(:grant, edge: freetown.edge, group: group)

    get :show, params: {id: member.profile.group_memberships.second}

    assert_redirected_to freetown.iri_path
  end

  test 'member should get show with page grant' do
    sign_in member
    create(:grant, edge: freetown.page.edge, group: group)

    get :show, params: {id: member.profile.group_memberships.second}

    assert_redirected_to freetown.page.iri_path
  end

  test 'member should get show with r' do
    sign_in member

    get :show, params: {id: member.profile.group_memberships.second, r: freetown.iri_path}

    assert_redirected_to freetown.iri_path
  end

  test 'member should not post create as json' do
    validate_valid_bearer_token
    sign_in member

    assert_differences [['GroupMembership.count', 0], ['Favorite.count', 0], ['Follow.count', 0]] do
      post :create, format: :json, params: {group_id: group, token: '1234567890'}
      assert_redirected_to group.group_memberships.first
    end
  end

  test 'member with group_memberships should post create as json' do
    validate_valid_bearer_token
    sign_in single_forum_group_member
    forum_edge_ids = single_forum_group.page.edge.children.where(owner_type: 'Forum').pluck(:id)
    forum_edge_ids.each do |forum_edge_id|
      Favorite.create!(user: member, edge_id: forum_edge_id)
    end

    assert_differences [['GroupMembership.count', 0], ['Favorite.count', 0], ['Follow.count', 0]] do
      post :create, format: :json, params: {group_id: single_forum_group, token: '1234567890'}
      assert_redirected_to single_forum_group.group_memberships.first
    end
  end

  test 'member should delete destroy own membership' do
    sign_in member

    assert_differences([['GroupMembership.count', 0], ['GroupMembership.active.count', -1]]) do
      delete :destroy, params: {id: member.profile.group_memberships.second}
    end

    assert_redirected_to freetown.page.iri_path
  end

  ####################################
  # As Administrator
  ####################################
  let(:administator) { create_administrator(freetown) }

  test 'administrator should not post create member' do
    sign_in administator

    assert_difference 'GroupMembership.count', 0 do
      post :create,
           params: {
             group_id: group,
             shortname: member.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_redirected_to settings_iri_path(freetown, tab: :groups)
    assert_analytics_not_collected
  end

  test 'administrator should not post create member json' do
    sign_in administator

    assert_difference 'GroupMembership.count', 0 do
      post :create,
           format: :json,
           params: {
             group_id: group,
             shortname: member.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_response 304
    assert_equal response.headers['Location'], group_membership_url(member.profile.group_memberships.second)
    assert_analytics_not_collected
  end

  test 'administrator should post create other' do
    sign_in administator
    user
    assert_difference 'GroupMembership.count', 1 do
      post :create,
           params: {
             group_id: group,
             shortname: user.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_redirected_to settings_iri_path(freetown, tab: :groups)
    assert_analytics_collected('memberships', 'create')
  end

  test 'administrator should not post create for staff group' do
    sign_in administator
    user
    assert_difference 'GroupMembership.count', 0 do
      post :create,
           params: {
             group_id: Group::STAFF_ID,
             shortname: user.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_not_authorized
    assert_analytics_not_collected
  end

  test 'administrator should post create other json' do
    sign_in administator
    user
    assert_difference 'GroupMembership.count', 1 do
      post :create,
           format: :json,
           params: {
             group_id: group,
             shortname: user.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_response 201
    expect_included(argu_url("/g/#{group.id}"))
    assert_equal response.headers['Location'], group_membership_url(GroupMembership.last)
    assert_analytics_collected('memberships', 'create')
  end

  test 'administrator should delete expire' do
    sign_in administator

    group_membership = create(:group_membership, parent: group)

    assert_differences([['GroupMembership.count', 0], ['GroupMembership.active.count', -1]]) do
      delete :destroy,
             params: {
               id: group_membership,
               r: settings_iri_path(freetown, tab: :groups)
             }
    end

    assert_redirected_to settings_iri_path(freetown, tab: :groups)
    assert_analytics_collected('memberships', 'destroy')
  end

  test 'administrator should get index' do
    sign_in administator

    get :index,
        params: {
          page_id: freetown.page.id,
          q: administator.first_name,
          thing: 'fg_shortname26end'
        }

    assert_equal parsed_body['data'].size, 1
    assert_response 200
  end

  test 'administrator should get index non found' do
    sign_in administator

    get :index,
        params: {
          page_id: freetown.page.id,
          q: 'wrong',
          thing: 'fg_shortname26end'
        }

    assert_equal parsed_body['data'].size, 0
    assert_response 200
  end

  ####################################
  # As Page
  ####################################
  test 'page should post create other' do
    sign_in administator
    user
    assert_difference 'GroupMembership.count', 1 do
      post :create,
           params: {
             actor_iri: freetown.page.iri,
             group_id: group,
             shortname: user.url,
             r: settings_iri_path(freetown, tab: :groups)
           }
    end

    assert_redirected_to settings_iri_path(freetown, tab: :groups)
    assert_analytics_collected('memberships', 'create')
  end
end

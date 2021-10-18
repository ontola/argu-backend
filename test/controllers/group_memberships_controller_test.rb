# frozen_string_literal: true

require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  define_freetown
  define_freetown('freetown2')
  let!(:group) { create(:group, parent: argu) }
  let!(:forum_group) { create(:group, parent: argu) }
  let!(:single_forum_group) { create(:group, parent: argu) }
  let!(:page_group) { create(:group, parent: argu) }
  let!(:grant) { create(:grant, edge: freetown, group: single_forum_group) }
  let!(:freetown_grant) { create(:grant, edge: freetown, group: forum_group) }
  let!(:freetown2_grant) { create(:grant, edge: freetown2, group: forum_group) }
  let!(:page_grant) { create(:grant, edge: argu, group: page_group) }
  let!(:member) { create(:group_membership, parent: group).member.profileable }
  let(:single_forum_group_member) { create(:group_membership, parent: single_forum_group).member.profileable }

  ####################################
  # As User not accepted terms
  ####################################
  let(:user_not_accepted) { create(:user, :not_accepted_terms) }

  test 'user not accepted terms should post create with valid token for single_forum_group' do
    validate_valid_bearer_token
    sign_in user_not_accepted

    assert_difference 'GroupMembership.count' => 1 do
      post :create,
           params: {
             parent_iri: parent_iri_for(single_forum_group),
             token: '1234567890'
           },
           format: :json
    end

    assert_response :created
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get show' do
    sign_in user

    get :show, params: {id: member.profile.group_memberships.second, root_id: argu.url}

    assert_not_authorized
  end

  test 'user should not post create without token' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {parent_iri: parent_iri_for(group)}, format: :json
    end

    assert_not_authorized
  end

  test 'user should not post create with invalid token' do
    validate_invalid_bearer_token
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, params: {parent_iri: parent_iri_for(group), token: '1234567890'}, format: :json
    end

    assert_not_authorized
  end

  test 'user should post create with valid token for single_forum_group' do
    validate_valid_bearer_token
    sign_in user

    assert_difference 'GroupMembership.count' => 1 do
      post :create, params: {parent_iri: parent_iri_for(single_forum_group), token: '1234567890'}, format: :json
    end
    assert_equal user.reload.following_type(freetown), 'never'

    assert_response :created
  end

  ####################################
  # As Member
  ####################################
  test 'member should get show' do
    sign_in member

    get :show, params: {id: member.profile.group_memberships.second, root_id: argu.url}, format: :nq

    assert_response :success
  end

  test 'member should get show with forum grant' do
    sign_in member
    create(:grant, edge: freetown, group: group)

    get :show, params: {id: member.profile.group_memberships.second, root_id: argu.url}, format: :nq

    assert_response :success
  end

  test 'member should get show with page grant' do
    sign_in member
    create(:grant, edge: argu, group: group)

    get :show, params: {id: member.profile.group_memberships.second, root_id: argu.url}, format: :nq

    assert_response :success
  end

  test 'member should get show with r' do
    sign_in member

    get :show,
        format: :nq,
        params: {id: member.profile.group_memberships.second, r: freetown.iri.path, root_id: argu.url}

    assert_response :success
  end

  test 'member should delete destroy own membership' do
    sign_in member

    assert_difference 'GroupMembership.count' => 0, 'GroupMembership.active.count' => -1 do
      delete :destroy,
             format: :json,
             params: {
               id: member.profile.group_memberships.second,
               root_id: argu.url,
               use_route: :group_membership
             }
    end

    assert_response :success
  end

  ####################################
  # As Administrator
  ####################################
  let(:administator) { create_administrator(freetown) }

  test 'administrator should delete expire' do
    sign_in administator

    group_membership = create(:group_membership, parent: group)

    assert_difference 'GroupMembership.count' => 0, 'GroupMembership.active.count' => -1 do
      delete :destroy,
             format: :json,
             params: {
               id: group_membership,
               r: settings_iri(freetown, tab: :groups),
               root_id: argu.url,
               use_route: :group_membership
             }
    end

    assert_response :no_content
  end

  test 'administrator should get index' do
    sign_in administator

    get :index,
        params: {
          parent_iri: parent_iri_for(group)
        },
        format: :nq

    assert_response :success
    view = expect_triple(group.collection_iri(:group_memberships), NS.ontola[:pages], nil).objects.first
    expect_triple(view, NS.as[:totalItems], 1)
  end
end

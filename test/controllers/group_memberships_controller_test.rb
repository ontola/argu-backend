require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:holland) { FactoryGirl.create(:forum, name: 'holland') }
  let!(:group) { FactoryGirl.create(:group, forum: holland) }

  ####################################
  # For users
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should not show new' do
    sign_in user

    get :new, group_id: group

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not post create' do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: group, profile_id: user.profile
    end

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not delete destroy' do
    sign_in user

    group_membership = FactoryGirl.create(:group_membership, group: group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_redirected_to root_path
  end

  ####################################
  # For owners
  ####################################
  let(:holland_owner) { create_owner(holland) }

  test 'should show new' do
    sign_in holland_owner

    get :new, group_id: group

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
    assert assigns(:membership)
  end

  test 'owner should post create' do
    sign_in holland_owner

    assert_difference 'GroupMembership.count', 1 do
      post :create, group_id: group, profile_id: user.profile
    end

    assert_redirected_to settings_forum_path(holland.url, tab: :groups)
    assert assigns(:forum)
    assert assigns(:membership)
  end

  test 'owner should delete destroy' do
    sign_in holland_owner

    group_membership = FactoryGirl.create(:group_membership, group: group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership
    end

    assert_redirected_to settings_forum_path(holland.url, tab: :groups)
  end


end

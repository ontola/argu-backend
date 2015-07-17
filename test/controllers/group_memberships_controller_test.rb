require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # For users
  ####################################

  test 'should not show new' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :new, group_id: group

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not post create' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: group, profile_id: profiles(:profile_one)
    end

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:membership)
  end

  test 'should not delete destroy' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')
    group_membership = FactoryGirl.create(:group_membership, group: group)

    assert_no_difference 'GroupMembership.count' do
      delete :destroy, id: group_membership
    end

    assert_redirected_to root_path
  end

  ####################################
  # For owners
  ####################################

  test 'should show new' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :new, group_id: group

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
    assert assigns(:membership)
  end

  test 'owner should post create' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    assert_difference 'GroupMembership.count', 1 do
      post :create, group_id: group, profile_id: profiles(:profile_one)
    end

    assert_redirected_to settings_forum_path('utrecht', tab: :groups)
    assert assigns(:forum)
    assert assigns(:membership)
  end

  test 'owner should delete destroy' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')
    group_membership = FactoryGirl.create(:group_membership, group: group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership
    end

    assert_redirected_to settings_forum_path('utrecht', tab: :groups)
  end


end

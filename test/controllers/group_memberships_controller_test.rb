require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_common_objects :user
  setup do
    @holland, @holland_owner = create_forum_owner_pair(type: :populated_forum)
    @group = create(:group, forum: @holland)
  end

  let(:holland) { create(:forum, name: 'holland') }
  let!(:group) { create(:group, forum: holland) }

  ####################################
  # As User
  ####################################
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
    sign_in @holland_owner

    get :new, group_id: @group

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
    assert assigns(:membership)
  end

  test 'owner should post create' do
    sign_in @holland_owner

    assert_difference 'GroupMembership.count', 1 do
      post :create, group_id: @group, profile_id: user.to_param
    end

    assert_redirected_to settings_forum_path(@holland.url, tab: :groups)
    assert assigns(:forum)
    assert assigns(:membership)
  end

  test 'owner should delete destroy' do
    sign_in @holland_owner

    group_membership = create(:group_membership,
                              group: @group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership
    end

    assert_redirected_to settings_forum_path(@holland.url, tab: :groups)
  end
end

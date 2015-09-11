require 'test_helper'

class GroupMembershipsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:forum, name: 'holland') }
  let!(:group) { FactoryGirl.create(:group, tenant: holland.name) }

  ####################################
  # For users
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should not show new', tenant: :holland do
    sign_in user

    get :new, group_id: group

    assert_redirected_to root_path
    assert_not assigns(:membership)
  end

  test 'should not post create', tenant: :holland do
    sign_in user

    assert_no_difference 'GroupMembership.count' do
      post :create, group_id: group, profile_id: user.profile
    end

    assert_redirected_to root_path
    assert_not assigns(:membership)
  end

  test 'should not delete destroy', tenant: :holland do
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
  let(:owner) { make_owner(holland) }

  test 'should show new', tenant: :holland do
    sign_in owner

    get :new, group_id: group

    assert_response 200
    assert assigns(:group)
    assert assigns(:membership)
  end

  test 'owner should post create', tenant: :holland do
    sign_in owner

    assert_difference 'GroupMembership.count', 1 do
      post :create, group_id: group, profile_id: user.to_param
    end

    assert_redirected_to settings_forums_path(tab: :groups)
    assert assigns(:membership)
  end

  test 'owner should delete destroy', tenant: :holland do
    sign_in owner

    group_membership = FactoryGirl.create(:group_membership, group: group)

    assert_difference 'GroupMembership.count', -1 do
      delete :destroy, id: group_membership
    end

    assert_redirected_to settings_forums_path(tab: :groups)
  end


end

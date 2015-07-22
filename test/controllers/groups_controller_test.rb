require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # For users
  ####################################

  test 'should not show new' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :new, id: group, forum_id: forums(:utrecht)

    assert_redirected_to root_path
    assert assigns(:forum)
  end

  test 'should not show edit' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :edit, id: group, forum_id: forums(:utrecht)

    assert_redirected_to root_path
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should not delete destroy' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    assert_no_difference 'Group.count' do
      delete :destroy!, id: group
    end

    assert_redirected_to root_path
  end

  ####################################
  # For owners
  ####################################

  test 'should show new' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :new, id: group, forum_id: forums(:utrecht)

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should show edit' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :edit, id: group, forum_id: forums(:utrecht)

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should delete destroy!' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    assert_difference 'Group.count', -1 do
      delete :destroy!, id: group
    end

    assert_response 303
    assert assigns(:forum)
    assert assigns(:group)
  end
end

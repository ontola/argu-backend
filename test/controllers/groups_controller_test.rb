require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should not show new' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :new, id: group, forum_id: forums(:utrecht)

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:group)
  end

  test 'should not show edit' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :edit, id: group, forum_id: forums(:utrecht)

    assert_redirected_to root_path
    assert assigns(:forum)
    assert assigns(:group)
  end

  test 'should not show add' do
    sign_in users(:user)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :add, id: group, forum_id: forums(:utrecht)

    assert_redirected_to root_path
    assert assigns(:forum)
    assert_not assigns(:group)
    assert_not assigns(:membership)
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

  test 'should show add' do
    sign_in users(:user_utrecht_owner)

    group = FactoryGirl.create(:group, forum_name: 'utrecht')

    get :add, id: group, forum_id: forums(:utrecht)

    assert_response 200
    assert assigns(:forum)
    assert assigns(:group)
    assert assigns(:membership)
  end

end

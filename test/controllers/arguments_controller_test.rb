require 'test_helper'

class ArgumentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in' do
    get :show, id: arguments(:one)

    assert_response 200
    assert assigns(:argument)
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, 'Trashed comments are visible'
  end

  ####################################
  # As user
  ####################################
  test 'should get show' do
    sign_in users(:user)

    get :show, id: arguments(:one)

    assert_response 200
    assert assigns(:argument)
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, 'Trashed comments are visible'
  end

  test 'should get new pro' do
    sign_in users(:user)

    get :new, forum_id: forums(:utrecht), motion_id: motions(:one).id, pro: 'pro'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).pro === true, "isn't assigned pro attribute"
  end

  test 'should get new con' do
    sign_in users(:user)

    get :new, forum_id: forums(:utrecht), motion_id: motions(:one).id, pro: 'con'

    assert_response 200
    assert assigns(:argument)
    assert assigns(:argument).motion == motions(:one)
    assert assigns(:argument).pro === false, "isn't assigned pro attribute"
  end

  test 'should get edit' do
    sign_in users(:user)

    get :edit, id: arguments(:one)

    assert_response 200
    assert assigns(:argument)
    assert assigns(:forum)
  end

  test 'should post create pro' do
    sign_in users(:user)

    assert_differences create_changes_array do
      assert_difference('Vote.count') do
        post :create, forum_id: forums(:utrecht), argument: {motion_id: motions(:one).id, pro: 'pro', title: 'Test argument pro', content: 'Test argument pro-tents', auto_vote: 'true'}
      end
    end

    argument = assigns(:ca).resource
    assert argument
    assert argument.motion == motions(:one)
    assert argument.title == 'Test argument pro', "title isn't assigned"
    assert argument.content == 'Test argument pro-tents', "content isn't assigned"
    assert argument.pro === true, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
  end

  test 'should post create con' do
    sign_in users(:user)

    assert_differences create_changes_array do
      assert_difference('Vote.count') do
        post :create, forum_id: forums(:utrecht), argument: {motion_id: motions(:one).id, pro: 'con', title: 'Test argument con', content: 'Test argument con-tents', auto_vote: 'true'}
      end
    end

    argument = assigns(:ca).resource
    assert argument
    assert argument.motion == motions(:one)
    assert argument.title == 'Test argument con', "title isn't assigned"
    assert argument.content == 'Test argument con-tents', "content isn't assigned"
    assert argument.pro === false, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
  end

  test 'should post create pro without auto_vote' do
    sign_in users(:user)

    assert_differences create_changes_array do
      assert_no_difference('Vote.count') do
        post :create, forum_id: forums(:utrecht), argument: {motion_id: motions(:one).id, pro: 'pro', title: 'Test argument pro', content: 'Test argument pro-tents', auto_vote: 'false'}
      end
    end
  end

  test 'should put update on own argument' do
    sign_in users(:user)

    put :update, id: arguments(:one), argument: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:argument)
    assert_equal 'New title', assigns(:argument).title
    assert_equal 'new contents', assigns(:argument).content
    assert_redirected_to assigns(:argument)
  end

  test "'should not put update on others' argument'" do
    sign_in users(:user2)

    put :update, id: arguments(:one), argument: {title: 'New title', content: 'new contents'}

    assert_equal arguments(:one), assigns(:argument)
  end

private
  def create_changes_array
    [['Argument.count', 1],
     ['Activity.count', 1],
     ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', 1],
     ['Notification.count', 1]]
  end
end

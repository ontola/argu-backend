require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in' do
    get :show, id: forums(:utrecht)
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  ####################################
  # As user
  ####################################
  test 'should get show' do
    sign_in users(:user)

    get :show, id: forums(:utrecht)
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  test 'should not show settings' do
    sign_in users(:user)

    get :settings, id: forums(:utrecht)
    assert_redirected_to root_path, 'Settings are publicly visible'
  end

  test 'should not show statistics' do
    sign_in users(:user)

    get :statistics, id: forums(:utrecht)
    assert_redirected_to root_path, 'Statistics are publicly visible'
  end

  test 'should not leak closed children to non-members' do
    sign_in users(:user)

    get :show, id: forums(:amsterdam)
    assert_response 200

    assert_nil assigns(:items), 'Closed forums are leaking content'
  end

  test 'should not show hidden to non-members' do
    sign_in users(:user)

    get :show, id: forums(:hidden)
    assert_response 404
    #assert_redirected_to root_path, 'Hidden forums are visible'
  end

  test 'should not put update on others question' do
    sign_in users(:user)

    put :update, id: forums(:utrecht), question: {title: 'New title', content: 'new contents'}
    assert_redirected_to root_path, 'Others can update questions'
  end

  test 'should get selector' do
    sign_in users(:user)

    get :selector
    assert_response 200, 'Selector broke'
    assert_not_nil assigns(:forums)
  end


  ####################################
  # As owner
  ####################################

  test 'should show settings and all tabs' do
    sign_in users(:user_utrecht_owner)

    get :settings, id: forums(:utrecht)
    assert_response 200
    assert assigns(:forum)

    [:general, :advanced, :groups, :privacy, :managers].each do |tab|
      get :settings, id: forums(:utrecht), tab: tab
      assert_response 200
      assert assigns(:forum)
    end
  end

  test 'should update settings' do
    sign_in users(:user_utrecht_owner)

    put :update, id: forums(:utrecht), forum: {
                     name: 'new name',
                     bio: 'new bio',
                     cover_photo: File.open('test/files/forums_controller_test/forum_update_carrierwave_image.jpg'),
                     profile_photo: File.open('test/files/forums_controller_test/forum_update_carrierwave_image.jpg')
                 }

    assert_redirected_to settings_forum_path(forums(:utrecht))
    assert assigns(:forum)
    assert_equal 'new name', assigns(:forum).reload.name
    assert_equal 'new bio', assigns(:forum).reload.bio
    assert_equal 2, assigns(:forum).lock_version, "Lock version didn't increase"
  end

  test 'should show settings/groups' do
    sign_in users(:user_utrecht_owner)

    get :settings, id: forums(:utrecht), tab: :groups

    assert_response :success
    assert assigns(:forum)
  end

  test 'should not show statistics yet' do
    sign_in users(:user_utrecht_owner)

    get :statistics, id: forums(:utrecht)
    assert_redirected_to root_url
    assert assigns(:forum)
    assert_nil assigns(:tags), "Doesn't assign tags"
    #assert_equal 2, assigns(:tags).length
  end


  ####################################
  # As manager
  ####################################

  test 'should show settings and some tabs' do
    sign_in users(:user_utrecht_manager_only)

    [:general, :advanced, :groups].each do |tab|
      get :settings, id: forums(:utrecht), tab: tab
      assert_response 200
      assert assigns(:forum)
    end

    [:privacy, :managers].each do |tab|
      get :settings, id: forums(:utrecht), tab: tab
      assert_redirected_to root_path
      assert assigns(:forum)
    end
  end
end

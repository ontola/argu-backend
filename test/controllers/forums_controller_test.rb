require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:cologne) { FactoryGirl.create(:closed_populated_forum, name: 'cologne') }
  let!(:helsinki) { FactoryGirl.create(:hidden_populated_forum, name: 'helsinki') }

  ####################################
  # As Guest
  ####################################
  test 'should get show when not logged in' do
    get :show, id: holland
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show' do
    sign_in user

    get :show, id: holland
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  test 'should not show settings' do
    sign_in user

    get :settings, id: holland
    assert_redirected_to root_path, 'Settings are publicly visible'
  end

  test 'should not show statistics' do
    sign_in user

    get :statistics, id: holland
    assert_redirected_to root_path, 'Statistics are publicly visible'
  end

  test 'should not leak closed children to non-members' do
    sign_in user

    get :show, id: cologne
    assert_response 200

    assert cologne.motions.count > 0
    assert_nil assigns(:items), 'Closed forums are leaking content'
  end

  test 'should not show hidden to non-members' do
    sign_in user

    get :show, id: helsinki
    assert_response 404, 'Hidden forums are visible'
  end

  test 'should not put update on others question' do
    sign_in user

    put :update, id: holland, question: {title: 'New title', content: 'new contents'}
    assert_redirected_to root_path, 'Others can update questions'
  end

  test 'should get selector' do
    sign_in user

    get :selector
    assert_response 200, 'Selector broke'
    assert_not_nil assigns(:forums)
  end

  ####################################
  # As Member
  ####################################
  let(:cologne_member) { create_member(cologne) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'should show closed children to members' do
    sign_in cologne_member

    get :show, id: cologne
    assert_response 200

    assert cologne.motions.count > 0
    assert assigns(:items), 'Closed forum content is not present'
  end

  test 'should show hidden to members' do
    sign_in helsinki_member

    get :show, id: helsinki
    assert_response 200
  end

  ####################################
  # As Owner
  ####################################
  let(:forum_pair) { create_forum_owner_pair({type: :populated_forum}) }

  test 'should show settings and all tabs' do
    forum, owner = forum_pair
    sign_in owner

    get :settings, id: forum
    assert_response 200
    assert assigns(:forum)

    [:general, :advanced, :groups, :privacy, :managers].each do |tab|
      get :settings, id: forum, tab: tab
      assert_response 200
      assert assigns(:forum)
    end
  end

  test 'should update settings' do
    forum, owner = forum_pair
    sign_in owner

    put :update,
        id: forum,
        forum: {
          name: 'new name',
          bio: 'new bio',
          cover_photo: File.open('test/files/forums_controller_test/forum_update_carrierwave_image.jpg'),
          profile_photo: File.open('test/files/forums_controller_test/forum_update_carrierwave_image.jpg')
        }

    assert_redirected_to settings_forum_path(forum.url, tab: :general)
    assert assigns(:forum)
    assert_equal 'new name', assigns(:forum).reload.name
    assert_equal 'new bio', assigns(:forum).reload.bio
    assert_equal 2, assigns(:forum).lock_version, "Lock version didn't increase"
  end

  test 'should show settings/groups' do
    forum, owner = forum_pair
    sign_in owner

    get :settings, id: forum, tab: :groups

    assert_response :success
    assert assigns(:forum)
  end

  test 'should not show statistics yet' do
    forum, owner = forum_pair
    sign_in owner

    get :statistics, id: forum
    assert_redirected_to root_url
    assert assigns(:forum)
    assert_nil assigns(:tags), "Doesn't assign tags"
    # assert_equal 2, assigns(:tags).length
  end


  ####################################
  # As Manager
  ####################################
  let(:holland_manager) { create_manager(holland) }

  test 'should show settings and some tabs' do
    sign_in holland_manager

    [:general, :advanced, :groups].each do |tab|
      get :settings, id: holland, tab: tab
      assert_response 200
      assert assigns(:forum)
    end

    [:privacy, :managers].each do |tab|
      get :settings, id: holland, tab: tab
      assert_redirected_to root_path
      assert assigns(:forum)
    end
  end
end

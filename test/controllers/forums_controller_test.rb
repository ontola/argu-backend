require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:freetown) { create(:forum, name: 'freetown') }
  let!(:holland) { create(:populated_forum, name: 'holland') }
  let!(:cologne) { create(:closed_populated_forum, name: 'cologne') }
  let!(:helsinki) { create(:hidden_populated_forum, name: 'helsinki') }

  let(:project) { create(:project, forum: holland, published_at: nil) }
  let(:q1) { create(:question, forum: holland, project: project) }
  let(:m1) { create(:motion, forum: holland, project: project) }
  def holland_nested_project_items
    [m1, q1]
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get show when not logged in' do
    get :show, id: holland
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
    assert_not assigns(:items).map(&:identifier).include?(q1.identifier),
               "Unpublished projects' questions are visible"
    assert_not assigns(:items).map(&:identifier).include?(m1.identifier),
               "Unpublished projects' motions are visible"
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show' do
    # Trigger creation of items
    holland_nested_project_items
    sign_in user

    get :show, id: holland
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
    assert_not assigns(:items).map(&:identifier).include?(q1.identifier),
               "Unpublished projects' questions are visible"
    assert_not assigns(:items).map(&:identifier).include?(m1.identifier),
               "Unpublished projects' motions are visible"
  end

  test 'user should not show settings' do
    sign_in user

    get :settings, id: freetown
    assert_redirected_to forum_path(freetown), 'Settings are publicly visible'
  end

  test 'should not show statistics' do
    sign_in user

    get :statistics, id: freetown
    assert_redirected_to forum_path(freetown), 'Statistics are publicly visible'
  end

  test 'user should not leak closed children to non-members' do
    sign_in user

    get :show, id: cologne
    assert_response 200

    assert cologne.motions.count > 0
    assert_nil assigns(:items), 'Closed forums are leaking content'
  end

  test 'user should not show hidden to non-members' do
    sign_in user

    get :show, id: helsinki
    assert_response 404, 'Hidden forums are visible'
  end

  test 'user should not put update on others question' do
    sign_in user

    put :update,
        id: holland,
        question: {
          title: 'New title',
          content: 'new contents'
        }
    assert_redirected_to forum_path(holland), 'Others can update questions'
  end

  test 'user should get selector' do
    sign_in user

    get :selector
    assert_response 200, 'Selector broke'
    assert_not_nil assigns(:forums)
  end

  ####################################
  # As Member
  ####################################
  let(:holland_member) { create_member(holland) }
  let(:cologne_member) { create_member(cologne) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'member should get show' do
    # Trigger creation of items
    holland_nested_project_items
    sign_in holland_member

    get :show, id: holland
    assert_response 200

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
    assert_not assigns(:items).map(&:identifier).include?(q1.identifier),
               "Unpublished projects' questions are visible"
    assert_not assigns(:items).map(&:identifier).include?(m1.identifier),
               "Unpublished projects' motions are visible"
  end

  test 'member should show closed children to members' do
    sign_in cologne_member

    get :show, id: cologne
    assert_response 200

    assert cologne.motions.count > 0
    assert assigns(:items), 'Closed forum content is not present'
  end

  test 'member should show hidden to members' do
    sign_in helsinki_member

    get :show, id: helsinki
    assert_response 200
  end

  ####################################
  # As Owner
  ####################################
  let(:forum_pair) { create_forum_owner_pair(type: :populated_forum) }

  test 'owner should show settings and all tabs' do
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

  test 'owner should update settings' do
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

  test 'owner should show settings/groups' do
    forum, owner = forum_pair
    sign_in owner

    get :settings, id: forum, tab: :groups

    assert_response :success
    assert assigns(:forum)
  end

  test 'owner should not show statistics yet' do
    forum, owner = forum_pair
    sign_in owner

    get :statistics, id: forum
    assert_redirected_to forum_path(forum)
    assert assigns(:forum)
    assert_nil assigns(:tags), "Doesn't assign tags"
    # assert_equal 2, assigns(:tags).length
  end

  ####################################
  # As Manager
  ####################################
  let(:holland_manager) { create_manager(holland) }

  test 'manager should show settings and some tabs' do
    sign_in holland_manager

    [:general, :advanced, :groups].each do |tab|
      get :settings, id: holland, tab: tab
      assert_response 200
      assert assigns(:forum)
    end

    [:privacy, :managers].each do |tab|
      get :settings, id: holland, tab: tab
      assert_redirected_to forum_path(holland)
      assert assigns(:forum)
    end
  end
end

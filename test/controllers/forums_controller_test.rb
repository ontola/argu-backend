require 'test_helper'

class ForumsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:cologne) { FactoryGirl.create(:closed_populated_forum, name: 'cologne') }
  let!(:helsinki) { FactoryGirl.create(:hidden_populated_forum, name: 'helsinki') }

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in', tenant: :holland do
    get :show
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  # Forum id's don't matter anymore, only the tentant decides
  test 'should not get show when not logged in', tenant: :helsinki do
    get :show
    assert_response 404
    assert_not_nil assigns(:forum)
    assert_nil assigns(:items)
  end

  ####################################
  # As user
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show', tenant: :holland do
    sign_in user

    get :show
    assert_response 200
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), 'Trashed motions are visible'
  end

  test 'should not show settings', tenant: :holland do
    sign_in user

    get :settings
    assert_redirected_to root_path, 'Settings are publicly visible'
  end

  test 'should not show statistics', tenant: :holland do
    sign_in user

    get :statistics
    assert_redirected_to root_path, 'Statistics are publicly visible'
  end

  test 'should not leak closed children to non-members', tenant: :cologne do
    sign_in user

    get :show
    assert_response 200

    assert cologne.motions.count > 0
    assert_nil assigns(:items), 'Closed forums are leaking content'
  end

  test 'should not show hidden to non-members', tenant: :helsinki do
    sign_in user

    get :show
    assert_response 404, 'Hidden forums are visible'
  end

  test 'should not put update on others question', tenant: :holland do
    sign_in user

    put :update, question: {title: 'New title', content: 'new contents'}
    assert_redirected_to root_path, 'Others can update questions'
  end

  test 'should get selector' do
    sign_in user

    get :selector
    assert_response 200, 'Selector broke'
    assert_not_nil assigns(:forums)
  end

  ####################################
  # As member
  ####################################
  let(:cologne_member) { create_member(cologne) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'should show closed children to members', tenant: :cologne do
    sign_in cologne_member

    get :show
    assert_response 200

    assert cologne.motions.count > 0
    assert assigns(:items), 'Closed forum content is not present'
  end

  test 'should show hidden to members', tenant: :helsinki do
    sign_in helsinki_member

    get :show
    assert_response 200
  end

  ####################################
  # As owner
  ####################################
  let(:owner_forum) { FactoryGirl.create(:populated_forum) }
  let(:owner_user) { create_owner(owner_forum) }

  test 'should show settings and all tabs', tenant: :owner_forum do
    sign_in owner_user

    get :settings
    assert_response 200
    assert assigns(:forum)

    [:general, :advanced, :groups, :privacy, :managers].each do |tab|
      get :settings, tab: tab
      assert_response 200
      assert assigns(:forum)
    end
  end

  test 'should update settings', tenant: :forum_pair do
    forum, owner = forum_pair
    sign_in owner

    put :update, forum: {
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

  test 'should not show statistics yet', tenant: :holland do
    forum, owner = forum_pair
    sign_in owner

    get :statistics, id: forum
    assert_redirected_to root_url
    assert assigns(:forum)
    assert_nil assigns(:tags), "Doesn't assign tags"
    #assert_equal 2, assigns(:tags).length
  end


  ####################################
  # As manager
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

require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { create(:forum) }
  let!(:project) { create(:project, :published, forum: freetown) }
  let!(:unpublished_project) { create(:project, forum: freetown) }
  let!(:helsinki) do
    create(:hidden_populated_forum,
           name: 'helsinki',
           visible_with_a_link: true)
  end
  let(:helsinki_key) { create(:access_token, item: helsinki) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get new' do
    get :new, forum_id: freetown

    assert_response 200
  end

  test 'guest should not get new on project' do
    get :new, project_id: project

    assert_redirected_to root_path
  end

  ####################################
  # As Spectator
  ####################################
  test 'spectator should get new' do
    get :new, forum_id: helsinki, at: helsinki_key.access_token

    assert_response 200
  end

  test 'spectator should not get new on project' do
    get :new, project_id: project, at: helsinki_key.access_token

    assert_redirected_to root_path
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get new' do
    sign_in user

    get :new, forum_id: freetown

    assert_response 200
  end

  test 'user should get new for helsinki' do
    sign_in user

    get :new, forum_id: helsinki

    assert_response 404
  end

  test 'user should not get new on project' do
    sign_in user

    get :new, project_id: project

    assert_redirected_to root_path
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(helsinki) }

  test 'member should get new' do
    sign_in member

    get :new, forum_id: freetown

    assert_response 200
  end

  test 'member should get new on project' do
    sign_in member

    get :new, project_id: project

    assert_response 200
  end

  test 'member should not get new on unpublished project' do
    sign_in member

    get :new, project_id: unpublished_project

    assert_redirected_to root_path
  end
end

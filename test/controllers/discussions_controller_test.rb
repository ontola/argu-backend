# frozen_string_literal: true
require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown
  let!(:project) { create(:project, argu_publication: build(:publication), parent: freetown.edge) }
  let!(:unpublished_project) { create(:project, parent: freetown.edge) }
  let!(:helsinki) do
    create_forum(
      name: 'helsinki',
      visibility: Forum.visibilities[:hidden],
      visible_with_a_link: true)
  end
  let!(:helsinki_project) { create(:project, argu_publication: build(:publication), parent: helsinki.edge) }
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

    assert_response 200
  end

  test 'guest should not get new on unpublished project' do
    get :new, project_id: unpublished_project

    assert_redirected_to root_path
  end

  test 'guest should not get new on closed forum project' do
    get :new, project_id: helsinki_project

    assert_redirected_to root_path
  end

  ####################################
  # As Spectator
  ####################################
  test 'spectator should get new' do
    get :new, forum_id: helsinki, at: helsinki_key.access_token

    assert_response 200
  end

  test 'spectator should get new on project' do
    get :new, project_id: project, at: helsinki_key.access_token

    assert_response 200
  end

  test 'spectator should not get new on unpublished project' do
    get :new, project_id: unpublished_project, at: helsinki_key.access_token

    assert_redirected_to root_path
  end

  test 'spectator should get new on closed forum project' do
    get :new, project_id: helsinki_project, at: helsinki_key.access_token

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

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

  test 'user should get new on project' do
    sign_in user

    get :new, project_id: project

    assert_response 200
  end

  test 'user should not get new on unpublished project' do
    sign_in user

    get :new, project_id: unpublished_project

    assert_redirected_to root_path
  end

  ####################################
  # As Member
  ####################################
  let(:freetown_member) { create_member(freetown) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'member should get new' do
    sign_in helsinki_member

    get :new, forum_id: freetown

    assert_response 200
  end

  test 'member should get new on project' do
    sign_in helsinki_member

    get :new, project_id: project

    assert_response 200
  end

  test 'member should not get new on unpublished project' do
    sign_in freetown_member

    get :new, project_id: unpublished_project

    assert_redirected_to root_path
  end

  ####################################
  # As Moderator
  ####################################
  let(:freetown_moderator) { create_moderator(freetown) }
  let(:project_moderator) { create_moderator(project) }
  let(:unpublished_moderator) { create_moderator(unpublished_project) }

  test 'moderator should get new' do
    sign_in freetown_moderator

    get :new, forum_id: freetown

    assert_response 200
  end

  test 'moderator should get new on project' do
    sign_in project_moderator

    get :new, project_id: project

    assert_response 200
  end

  test 'moderator should get new on unpublished project' do
    sign_in unpublished_moderator

    get :new, project_id: unpublished_project

    assert_response 200
  end

  test 'moderator should get new on nested unpublished project' do
    sign_in freetown_moderator

    get :new, project_id: unpublished_project

    assert_response 200
  end
end

# frozen_string_literal: true
require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  define_freetown
  define_helsinki
  let(:project) { create(:project, parent: freetown.edge) }
  let(:unpublished_project) do
    create(:project,
           parent: freetown.edge,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let(:helsinki_project) { create(:project, parent: helsinki.edge) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get new' do
    get :new, params: {forum_id: freetown}

    assert_response 200
  end

  test 'guest should not get new on project' do
    get :new, params: {project_id: project}

    assert_response 200
  end

  test 'guest should not get new on unpublished project' do
    get :new, params: {project_id: unpublished_project}

    assert_response 403
  end

  test 'guest should not get new on closed forum project' do
    get :new, params: {project_id: helsinki_project}

    assert_response 403
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get new' do
    sign_in user

    get :new, params: {forum_id: freetown}

    assert_response 200
  end

  test 'user should get new for helsinki' do
    sign_in user

    get :new, params: {forum_id: helsinki}

    assert_response 404
  end

  test 'user should get new on project' do
    sign_in user

    get :new, params: {project_id: project}

    assert_response 200
  end

  test 'user should not get new on unpublished project' do
    sign_in user

    get :new, params: {project_id: unpublished_project}

    assert_response 403
  end

  ####################################
  # As Member
  ####################################
  let(:freetown_member) { create_member(freetown) }
  let(:helsinki_member) { create_member(helsinki) }

  test 'member should get new' do
    sign_in helsinki_member

    get :new, params: {forum_id: freetown}

    assert_response 200
  end

  test 'member should get new on project' do
    sign_in helsinki_member

    get :new, params: {project_id: project}

    assert_response 200
  end

  test 'member should not get new on unpublished project' do
    sign_in freetown_member

    get :new, params: {project_id: unpublished_project}

    assert_response 403
  end
end

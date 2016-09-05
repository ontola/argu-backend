require 'test_helper'

class ArgumentsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  let!(:motion) do
    create(:motion,
           :with_follower,
           parent: freetown.edge,
           creator: create(:user,
                           :follows_reactions_directly,
                           :viewed_notifications_hour_ago)
                      .profile)
  end
  let(:argument) do
    create(:argument,
           parent: motion.edge)
  end

  let(:project) { create(:project, parent: freetown.edge) }
  let(:project_motion) { create(:motion, parent: project.edge) }
  let(:project_argument) do
    create(:argument,
           parent: project_motion.edge)
  end

  let(:pub_project) do
    create(:project,
           argu_publication: build(:publication),
           parent: freetown.edge)
  end
  let(:pub_project_motion) { create(:motion, parent: pub_project.edge) }
  let(:pub_project_argument) do
    create(:argument,
           parent: pub_project_motion.edge)
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get show' do
    get :show, params: {id: argument}

    assert_response 200
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' },
               'Trashed comments are visible'
  end

  test 'guest should not get show nested unpublished' do
    get :show, params: {id: project_argument}

    assert_redirected_to forum_url(freetown)
  end

  test 'guest should get show nested published' do
    get :show, params: {id: pub_project_argument}

    assert_response 200
  end

  test 'guest should not get new' do
    get :new, params: {forum_id: freetown, motion_id: motion.id, pro: 'pro'}

    assert_response 302
    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show' do
    sign_in user

    get :show, params: {id: argument}

    assert_response 200
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' },
               'Trashed comments are visible'
  end

  test 'user should not get show nested unpublished' do
    sign_in user

    get :show, params: {id: project_argument}

    assert_redirected_to forum_url(freetown)
  end

  test 'user should get show nested published' do
    sign_in user

    get :show, params: {id: pub_project_argument}

    assert_response 200
  end

  test 'user should not get new' do
    sign_in user

    get :new, params: {forum_id: freetown, motion_id: motion.id, pro: 'pro'}

    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:member_argument) do
    create(:argument,
           parent: motion.edge,
           creator: member.profile)
  end

  test 'member should not get show nested unpublished' do
    sign_in member

    get :show, params: {id: project_argument}

    assert_redirected_to forum_url(freetown)
  end

  test 'member should get show nested published' do
    sign_in member

    get :show, params: {id: pub_project_argument}

    assert_response 200
  end

  test 'member should get new pro' do
    sign_in member

    get :new, params: {forum_id: freetown, motion_id: motion.id, pro: 'pro'}

    assert_response 200
    assert assigns(:resource)
    assert assigns(:resource).motion == motion
    assert assigns(:resource).pro === true, "isn't assigned pro attribute"
  end

  test 'member should get new' do
    sign_in member

    get :new, params: {forum_id: freetown, motion_id: motion.id, pro: 'con'}

    assert_response 200
    assert assigns(:resource)
    assert assigns(:resource).motion == motion
    assert assigns(:resource).pro === false, "isn't assigned pro attribute"
  end

  test 'member should get edit' do
    sign_in member

    get :edit, params: {id: member_argument}

    assert_response 200
  end

  test 'member should post create pro' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           params: {
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'pro',
               title: 'Test argument pro',
               content: 'Test argument pro-tents',
               auto_vote: 'true'
             }
           }
    end

    argument = assigns(:create_service).resource
    assert argument
    assert argument.motion == motion
    assert argument.title == 'Test argument pro', "title isn't assigned"
    assert argument.content == 'Test argument pro-tents', "content isn't assigned"
    assert argument.pro === true, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
    assert_analytics_collected('arguments', 'create')
  end

  test 'member should post create con' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           params: {
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'con',
               title: 'Test argument con',
               content: 'Test argument con-tents',
               auto_vote: 'true'
             }
           }
    end

    argument = assigns(:create_service).resource
    assert argument
    assert argument.motion == motion
    assert argument.title == 'Test argument con', "title isn't assigned"
    assert argument.content == 'Test argument con-tents', "content isn't assigned"
    assert argument.pro === false, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
    assert_analytics_collected('arguments', 'create')
  end

  test 'member should post create pro without auto_vote' do
    sign_in member

    assert_differences create_changes_array(false) do
      post :create,
           params: {
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'pro',
               title: 'Test argument pro',
               content: 'Test argument pro-tents',
               auto_vote: 'false'
             }
           }
    end
    assert_analytics_collected('arguments', 'create')
  end

  test 'member should put update on own argument' do
    sign_in member

    put :update,
        params: {
          id: member_argument,
          argument: {
            title: 'New title',
            content: 'new contents'
          }
        }

    assert_not_nil assigns(:resource)
    assert_equal 'New title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
    assert_redirected_to assigns(:resource)
  end

  test "'member should not put update on others' argument'" do
    sign_in member

    put :update,
        params: {
          id: argument,
          argument: {
            title: 'New title',
            content: 'new contents'
          }
        }

    assert_not_authorized
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should delete trash' do
    sign_in manager
    argument # trigger

    assert_differences([['Argument.trashed(false).count', -1],
                        ['Argument.trashed_only.count', 1]]) do
      delete :trash,
             params: {id: argument}
    end

    assert_redirected_to argument.motion
  end

  test 'manager should delete destroy' do
    sign_in manager
    argument.trash

    assert_differences([['Argument.trashed(false).count', 0],
                        ['Edge.count', -1],
                        ['Argument.trashed_only.count', -1]]) do
      delete :destroy,
             params: {id: argument}
    end

    assert_redirected_to argument.motion
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { freetown.page.owner.profileable }

  test 'owner should delete trash' do
    sign_in owner
    argument # trigger

    assert_differences([['Argument.trashed(false).count', -1],
                        ['Argument.trashed_only.count', 1]]) do
      delete :trash,
             params: {id: argument}
    end

    assert_redirected_to argument.motion
  end

  test 'owner should delete destroy' do
    sign_in owner
    argument.trash

    assert_differences([['Argument.trashed(false).count', 0],
                        ['Edge.count', -1],
                        ['Argument.trashed_only.count', -1]]) do
      delete :destroy,
             params: {id: argument}
    end

    assert_redirected_to argument.motion
  end

  private

  def create_changes_array(auto_vote = true)
    c = [['Argument.count', 1],
         ['Activity.count', auto_vote ? 2 : 1],
         ['Notification.count', 2]]
    if auto_vote
      c.concat([['Edge.count', 2], ['Vote.count', 1]])
    else
      c.concat([['Edge.count', 1], ['Vote.count', 0]])
    end
    c
  end
end

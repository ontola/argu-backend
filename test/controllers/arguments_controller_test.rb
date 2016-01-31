require 'test_helper'

class ArgumentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:freetown) { FactoryGirl.create(:forum) }
  let(:motion) { FactoryGirl.create(:motion, forum: freetown) }
  let!(:follow) do
    FactoryGirl.create(:follow,
                       followable: motion,
                       follower: FactoryGirl.create(:user, :follows_email))
  end
  let(:argument) do
    FactoryGirl.create(:argument,
                       forum: freetown,
                       motion: motion)
  end

  let(:project) { create(:project, forum: freetown) }
  let(:project_motion) { create(:motion, forum: freetown, project: project) }
  let(:project_argument) do
    FactoryGirl.create(:argument,
                       forum: freetown,
                       motion: project_motion)
  end

  let(:pub_project) { create(:project, :published, forum: freetown) }
  let(:pub_project_motion) { create(:motion, forum: freetown, project: pub_project) }
  let(:pub_project_argument) do
    FactoryGirl.create(:argument,
                       forum: freetown,
                       motion: pub_project_motion)
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get show' do
    get :show, id: argument

    assert_response 200
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' },
               'Trashed comments are visible'
  end

  test 'guest should not get show nested unpublished' do
    get :show, id: project_argument

    assert_redirected_to forum_url(freetown)
  end

  test 'guest should get show nested published' do
    get :show, id: pub_project_argument

    assert_response 200
  end

  test 'guest should not get new' do
    get :new, forum_id: freetown, motion_id: motion.id, pro: 'pro'

    assert_response 302
    assert assigns(:_not_a_user_caught)
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get show' do
    sign_in user

    get :show, id: argument

    assert_response 200
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' },
               'Trashed comments are visible'
  end

  test 'user should not get show nested unpublished' do
    sign_in user

    get :show, id: project_argument

    assert_redirected_to forum_url(freetown)
  end

  test 'user should get show nested published' do
    sign_in user

    get :show, id: pub_project_argument

    assert_response 200
  end

  test 'user should not get new' do
    sign_in user

    get :new, forum_id: freetown, motion_id: motion.id, pro: 'pro'

    assert assigns(:_not_a_member_caught)
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:member_argument) { FactoryGirl.create(:argument,
                                      forum: freetown,
                                      motion: motion,
                                      creator: member.profile) }

  test 'member should not get show nested unpublished' do
    sign_in member

    get :show, id: project_argument

    assert_redirected_to forum_url(freetown)
  end

  test 'member should get show nested published' do
    sign_in member

    get :show, id: pub_project_argument

    assert_response 200
  end

  test 'member should get new pro' do
    sign_in member

    get :new, forum_id: freetown, motion_id: motion.id, pro: 'pro'

    assert_response 200
    assert assigns(:resource)
    assert assigns(:resource).motion == motion
    assert assigns(:resource).pro === true, "isn't assigned pro attribute"
  end

  test 'member should get new' do
    sign_in member

    get :new, forum_id: freetown, motion_id: motion.id, pro: 'con'

    assert_response 200
    assert assigns(:resource)
    assert assigns(:resource).motion == motion
    assert assigns(:resource).pro === false, "isn't assigned pro attribute"
  end

  test 'member should get edit' do
    sign_in member

    get :edit, id: member_argument

    assert_response 200
  end

  test 'member should post create pro' do
    sign_in member

    assert_differences create_changes_array do
      assert_difference('Vote.count') do
        post :create,
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'pro',
               title: 'Test argument pro',
               content: 'Test argument pro-tents',
               auto_vote: 'true'
             }
      end
    end

    argument = assigns(:ca).resource
    assert argument
    assert argument.motion == motion
    assert argument.title == 'Test argument pro', "title isn't assigned"
    assert argument.content == 'Test argument pro-tents', "content isn't assigned"
    assert argument.pro === true, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
  end

  test 'member should post create con' do
    sign_in member

    assert_differences create_changes_array do
      assert_difference('Vote.count') do
        post :create,
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'con',
               title: 'Test argument con',
               content: 'Test argument con-tents',
               auto_vote: 'true'
             }
        assert true
      end
    end

    argument = assigns(:ca).resource
    assert argument
    assert argument.motion == motion
    assert argument.title == 'Test argument con', "title isn't assigned"
    assert argument.content == 'Test argument con-tents', "content isn't assigned"
    assert argument.pro === false, "isn't assigned pro attribute"
    assert_redirected_to argument.motion
  end

  test 'member should post create pro without auto_vote' do
    sign_in member

    assert_differences create_changes_array do
      assert_no_difference('Vote.count') do
        post :create,
             forum_id: freetown,
             argument: {
               motion_id: motion.id,
               pro: 'pro',
               title: 'Test argument pro',
               content: 'Test argument pro-tents',
               auto_vote: 'false'
             }
      end
    end
  end

  test 'member should put update on own argument' do
    sign_in member

    put :update,
        id: member_argument,
        argument: {
          title: 'New title',
          content: 'new contents'
        }

    assert_not_nil assigns(:resource)
    assert_equal 'New title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
    assert_redirected_to assigns(:resource)
  end

  test "'member should not put update on others' argument'" do
    sign_in member

    put :update,
        id: argument,
        argument: {
          title: 'New title',
          content: 'new contents'
        }

    assert assigns(:_not_authorized_caught)
  end

  private

  def create_changes_array
    [['Argument.count', 1],
     ['Activity.count', 1],
     ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', 1],
     ['Notification.count', 2]]
  end
end

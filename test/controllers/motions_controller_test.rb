require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let(:subject) { FactoryGirl.create(:motion, forum: holland) }

  ####################################
  # As Guest
  ####################################
  test 'should get show when not logged in' do
    get :show, id: motions(:one)

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) },
               'Trashed arguments are visible'
  end

  test 'should not get edit when not logged in' do
    get :edit, id: motions(:one)

    assert_redirected_to new_user_session_path(r: edit_motion_path(motions(:one)))
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show' do
    sign_in users(:user)

    get :show, id: motions(:one)

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) },
               'Trashed arguments are visible'
  end

  test 'should get new' do
    sign_in users(:user)

    get :new, forum_id: forums(:utrecht)

    assert_response 200
    assert_not_nil assigns(:motion)
  end

  test 'should get edit' do
    sign_in users(:user)

    get :edit, id: motions(:one)

    assert_response 200
    assert assigns(:motion)
    assert assigns(:forum)
  end

  test 'should post create' do
    sign_in users(:user)

    assert_differences create_changes_array do
      post :create, forum_id: :utrecht, motion: {title: 'Motion', content: 'Contents'}
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource)
  end

  test 'should show tutorial only on first post create' do
    sign_in user
    FactoryGirl.create(:membership, profile: user.profile, forum: holland)

    assert_differences create_changes_array do
      post :create, forum_id: holland, motion: {title: 'Motion', content: 'Contents'}
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource, start_motion_tour: true)

    assert_differences create_changes_array(false) do
      post :create, forum_id: holland, motion: {title: 'Motion2', content: 'Contents'}
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource)
  end

  test 'should not post create without create_without_question' do
    sign_in users(:user)

    assert_differences [['Motion.count', 0],
                        ['Activity.count', 0]] do
      post :create,
           forum_id: :no_create_without_question,
           motion: {
             title: 'Motion',
             content: 'Contents'
           }
    end
    assert_nil assigns(:cm)
    assert_response 200
  end

  test 'should post create without create_without_question with question' do
    sign_in users(:user2)

    assert_differences create_changes_array do
      post :create,
           forum_id: :no_create_without_question,
           motion: {
             title: 'Motion',
             content: 'Contents',
             question_id: questions(:question_one_no_create_without_question).id
           }
    end
    assert_not_nil assigns(:cm).resource
    assert assigns(:cm).resource.persisted?
    assert_redirected_to motion_path(assigns(:cm).resource)
  end

  test 'should not put update on others motion' do
    sign_in users(:user2)

    put :update, id: motions(:one), motion: {title: 'New title', content: 'new contents'}

    assert_equal motions(:one), assigns(:motion)
  end

  test 'should not get convert' do
    sign_in users(:user)

    get :convert, motion_id: motions(:one)
    assert_redirected_to root_url
  end

  test 'should not put convert' do
    sign_in users(:user)

    put :convert, motion_id: motions(:one)
    assert_redirected_to root_url
  end

  test 'should not get move' do
    sign_in users(:user)

    get :move, motion_id: motions(:one)
    assert_redirected_to root_url
  end

  test 'should not put move' do
    sign_in users(:user)

    put :move, motion_id: motions(:one)
    assert_redirected_to root_url
  end

  ####################################
  # As Page
  ####################################
  let(:page) { create_member holland, FactoryGirl.create(:page) }


  test 'page should post create' do
    sign_in page.owner.profileable
    change_actor page

    assert_differences create_changes_array do
      post :create,
           forum_id: holland,
           motion: FactoryGirl.attributes_for(:motion)
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource,
                                     start_motion_tour: true)
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_member(holland) }
  let(:owner_motion) { FactoryGirl.create(:motion,
                                          creator: owner.profile,
                                          forum: holland) }

  test 'owner should put update' do
    sign_in users(:user)

    put :update, id: motions(:one), motion: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:motion)
    assert_equal 'New title', assigns(:motion).title
    assert_equal 'new contents', assigns(:motion).content
    assert_redirected_to motion_url(assigns(:motion))
  end

  test 'owner should render form for faulty put update' do
    sign_in owner

    put :update,
        id: owner_motion,
        motion: {
            title: 't',
            content: 'new contents'
        }

    assert_response 200
    assert assigns(:motion).changed?
  end

  ####################################
  # As Staff
  ####################################
  # Currently only staffers can convert items
  test 'should get convert' do
    sign_in users(:user_thom)

    get :convert, motion_id: motions(:one)
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put convert' do
    sign_in users(:user_thom)

    put :convert!, motion_id: motions(:one), motion: {f_convert: 'questions'}
    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Question, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    assert_equal 0, assigns(:result)[:old].arguments.count

    assert_equal 0, assigns(:result)[:old].taggings.count
    assert_equal 2, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal 2, assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count

  end

  # Currently only staffers can move items
  test 'should get move' do
    sign_in users(:user_thom)

    get :move, motion_id: motions(:one)
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put move!' do
    sign_in users(:user_thom)

    assert_differences [['forums(:utrecht).reload.motions_count', -1], ['forums(:amsterdam).reload.motions_count', 1]] do
      put :move!, motion_id: motions(:one), motion: { forum_id: forums(:amsterdam).id }
    end
    assert_redirected_to assigns(:motion)

    assert assigns(:motion)
    assert_equal forums(:amsterdam), assigns(:motion).forum
    forum_id = forums(:amsterdam).id
    assigns(:motion).arguments.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert assigns(:motion).questions.blank?
    assigns(:motion).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:motion).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end

  end

  protected

  # Detect the changes that should go hand in hand with object creation
  # @param notifications [Boolean] Set to false if an object is created twice for the same follower
  def create_changes_array(notifications = true)
    c = [['Motion.count', 1],
         ['Activity.count', 1],
         ['Notification.count', 1]]
    c << ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', 1] if notifications
    c
  end
end

require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { FactoryGirl.create(:forum, name: 'freetown') }
  let!(:follower) { FactoryGirl.create(:follow, followable: freetown) }
  let(:question) do
    FactoryGirl.create(:question,
                       forum: freetown,
                       creator: FactoryGirl.create(:profile_direct_email))
  end
  let(:subject) { FactoryGirl.create(:motion, :with_arguments, forum: freetown) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get show when not logged in' do
    get :show, id: subject

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert subject.arguments.where(is_trashed: true).count > 0,
           'No trashed arguments to test on'
    assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) },
               'Trashed arguments are visible'
  end

  test 'guest should not get edit when not logged in' do
    get :edit, id: subject

    assert_redirected_to new_user_session_path(r: edit_motion_path(subject))
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get show' do
    sign_in user

    get :show, id: subject

    assert_response 200
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:vote)

    assert subject.arguments.any?(&:is_trashed?),
           'No trashed arguments to test'
    assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) },
               'Trashed arguments are visible'
  end

  test 'user should get new' do
    sign_in user

    get :new, forum_id: freetown

    assert_response 200
    assert_not_a_member
  end

  test 'user should show tutorial only on first post create' do
    sign_in user
    FactoryGirl.create(:membership, profile: user.profile, forum: freetown)

    assert_differences create_changes_array do
      post :create, forum_id: freetown, motion: {title: 'Motion', content: 'Contents'}
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource, start_motion_tour: true)

    assert_differences create_changes_array(false) do
      post :create, forum_id: freetown, motion: {title: 'Motion2', content: 'Contents'}
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource)
  end

  test 'user should not get convert' do
    sign_in user

    get :convert, motion_id: subject
    assert_redirected_to root_url
  end

  test 'user should not put convert' do
    sign_in user

    put :convert, motion_id: subject
    assert_redirected_to root_url
  end

  test 'user should not get move' do
    sign_in user

    get :move, motion_id: subject
    assert_redirected_to root_url
  end

  test 'user should not put move' do
    sign_in user

    put :move, motion_id: subject
    assert_redirected_to root_url
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should get new' do
    sign_in member

    get :new, forum_id: freetown

    assert_response 200
    assert_not_nil assigns(:motion)
  end

  test 'member should post create' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           motion: {
             title: 'Motion',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource,
                                     start_motion_tour: true)
  end

  test 'member should post create with question' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           motion: {
             title: 'Motion',
             content: 'Contents',
             question_answers_attributes: {
               '0' => {
                 question_id: question.id
               }
             }
           }
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert assigns(:cm).resource.reload.questions.include?(question)
    assert_redirected_to motion_path(assigns(:cm).resource,
                                     start_motion_tour: true)
  end

  test 'member should keep data on erroneous post create' do
    sign_in member

    assert_differences create_changes_array(nil, 0) do
      post :create,
           forum_id: freetown,
           motion: {
             title: 'Motion',
             content: 'C',
             question_answers_attributes: {
               '0' => {
                 question_id: question.id
               }
             }
           }
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_response 200

    assert_select "[name=motion[title]]", 'Motion'
    assert_select "[name=motion[content]]", 'C'
    assert_select "[name=motion[question_answers_attributes][0][question_id]]", question.id.to_s
  end

  test 'member should not put update on others motion' do
    sign_in member

    put :update,
        id: subject,
        motion: {
          title: 'New title',
          content: 'new contents'
        }

    assert_redirected_to root_path
    assert_equal subject, assigns(:motion)
  end

  let(:no_create_without_question) do
    forum = FactoryGirl.create(:forum)
    FactoryGirl.create(:rule,
                       model_type: 'Motion',
                       action: 'create_without_question?',
                       role: 'member',
                       permit: false,
                       context_type: 'Forum',
                       context_id: forum.id,
                       trickles: Rule.trickles[:trickles_down])
    forum
  end
  let(:no_create_question) do
    user = FactoryGirl.create(:user, :follows_email)
    FactoryGirl.create(:question,
                       forum: no_create_without_question,
                       creator: user.profile)
  end
  let(:no_create_member) { create_member(no_create_without_question) }

  test 'member should not post create without create_without_question' do
    sign_in no_create_member

    assert_differences [['Motion.count', 0],
                        ['Activity.count', 0]] do
      post :create,
           forum_id: no_create_without_question,
           motion: {
             title: 'Motion',
             content: 'Contents'
           }
    end
    assert_redirected_to root_path
    assert_not_authorized
  end

  test 'member should post create without create_without_question with question' do
    sign_in no_create_member

    assert_differences create_changes_array do
      post :create,
           forum_id: no_create_without_question,
           motion: {
             title: 'Motion',
             content: 'Contents',
             question_answers_attributes: {
               '0' => {
                 question_id: no_create_question
               }
             }
           }
      puts
    end
    assert_not_nil assigns(:cm).resource
    assert assigns(:cm).resource.persisted?
    assert assigns(:cm).resource.questions.include?(no_create_question)
    assert_redirected_to motion_path(assigns(:cm).resource, start_motion_tour: true)
  end


  ####################################
  # As Page
  ####################################
  let(:page) { create_member freetown, FactoryGirl.create(:page) }


  test 'page should post create' do
    sign_in page.owner.profileable
    change_actor page

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           motion: FactoryGirl.attributes_for(:motion)
    end
    assert_not_nil assigns(:cm).resource
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:cm).resource,
                                     start_motion_tour: true)
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(freetown) }
  let(:creator_motion) do
    FactoryGirl.create(:motion,
                       creator: creator.profile,
                       forum: freetown)
  end

  test 'creator should get edit' do
    sign_in creator

    get :edit, id: creator_motion

    assert_response 200
    assert assigns(:motion)
    assert assigns(:forum)
  end

  test 'creator should put update' do
    sign_in creator

    put :update,
        id: creator_motion,
        motion: {
          title: 'New title',
          content: 'new contents'
        }

    assert_not_nil assigns(:motion)
    assert_equal 'New title', assigns(:motion).title
    assert_equal 'new contents', assigns(:motion).content
    assert_redirected_to motion_url(assigns(:motion))
  end

  test 'creator should render form for faulty put update' do
    sign_in creator

    put :update,
        id: creator_motion,
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
  let(:staff) { FactoryGirl.create(:user, :staff) }

  let(:forum_from) { FactoryGirl.create(:forum) }
  let(:forum_to) { FactoryGirl.create(:forum) }
  let(:motion_move) do
    FactoryGirl.create(:motion,
                       :with_arguments,
                       :with_votes,
                       forum: forum_from)
  end

  # Currently only staffers can convert items
  test 'staff should get convert' do
    sign_in staff

    get :convert, motion_id: subject
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'staff should put convert' do
    sign_in staff

    vote_count = motion_move.votes.count
    assert vote_count > 0,
           'no votes to test'

    put :convert!,
        motion_id: motion_move,
        motion: {
          f_convert: 'questions'
        }
    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Question, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    assert_equal 0, assigns(:result)[:old].arguments.count

    # assert_equal 0, assigns(:result)[:old].taggings.count
    # assert_equal 2, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal vote_count,
                 assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count

  end

  # Currently only staffers can move items
  test 'staff should get move' do
    sign_in staff

    get :move, motion_id: subject
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'staff should put move!' do
    sign_in staff

    assert_differences [['forum_from.reload.motions_count', -1],
                        ['forum_to.reload.motions_count', 1]] do
      put :move!,
          motion_id: motion_move,
          motion: {forum_id: forum_to.id}
    end
    assert_redirected_to assigns(:motion)

    assert assigns(:motion)
    assert_equal forum_to, assigns(:motion).forum
    forum_id = forum_to.id
    assert assigns(:motion).arguments.count > 0
    assigns(:motion).arguments.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert assigns(:motion).questions.blank?
    assert assigns(:motion).activities.count > 0
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
  def create_changes_array(notifications = true, count = 1)
    c = [['Motion.count', count],
         ['Activity.count', count],
         ['Notification.count', count]]
    c << ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', count] if notifications
    c
  end
end

require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @freetown, @freetown_owner = create_forum_owner_pair
  end

  let!(:freetown) { FactoryGirl.create(:forum, :with_follower, name: 'freetown') }
  subject do
    q = FactoryGirl.create(:question, forum: freetown)
    FactoryGirl.create(:motion, forum: freetown, question: q)
    FactoryGirl.create(:motion, forum: freetown, question: q, is_trashed: true)
    q
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should 404 on nonexistent id' do
    get :show, id: 'none'

    assert_response 404
  end

  test 'guest should get show' do
    get :show, id: subject
    assert_response 200

    assert subject.motions.any?(&:is_trashed?), 'No trashed motions to test'
    assert_not assigns(:motions).any? { |motion| motion.is_trashed? }, 'Trashed motions are visible'
  end

  test 'guest should not get new' do
    get :new,
        forum_id: freetown,
        question_id: subject.id

    assert assigns(:_not_a_user_caught)
    assert_response 302
  end

  test 'guest should not post create' do
    assert_no_difference 'Question.count' do
      post :create,
           forum_id: freetown,
           question: attributes_for(:question)
    end

    assert assigns(:_not_a_user_caught)
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get show' do
    sign_in user

    get :show, id: subject
    assert_response 200

    assert subject.motions.any?(&:is_trashed?), 'No trashed motions to test'
    assert_not assigns(:motions).any? { |motion| motion.is_trashed? }, 'Trashed motions are visible'
  end

  test 'user should 404 on nonexistent id' do
    sign_in user

    get :show, id: 'none'

    assert_response 404
  end

  test 'user should not get new' do
    sign_in user

    get :new,
        forum_id: freetown,
        question_id: subject.id

    assert assigns(:_not_a_member_caught)
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference 'Question.count' do
      post :create,
           forum_id: freetown,
           question: attributes_for(:question)
    end

    assert assigns(:_not_a_member_caught)
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:member_question) { FactoryGirl.create(:question, forum: freetown, creator: member.profile) }

  test 'member should get new' do
    sign_in member

    get :new, forum_id: freetown
    assert_response 200
    assert_not_nil assigns(:resource)
  end

  test 'member should 404 on nonexistent id' do
    sign_in member

    get :show, id: 'none'

    assert_response 404
  end

  test 'member should post create' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           question: {
             title: 'Question',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:cq).resource
    assert_redirected_to question_url(assigns(:cq).resource)
  end

  test 'member should put update on own question' do
    sign_in member

    put :update,
        id: member_question,
        question: {
          title: 'New title',
          content: 'new contents'
        }

    assert_not_nil assigns(:resource)
    assert_equal 'New title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
    assert_redirected_to question_url(assigns(:resource))
  end

  test 'should not put update on others question' do
    sign_in create_member(freetown)

    put :update,
        id: member_question,
        question: {
          title: 'New title',
          content: 'new contents'
        }

    assert_not_nil assigns(:_not_authorized_caught)
  end

  test 'should not get convert' do
    sign_in member

    get :convert, question_id: subject
    assert_not_nil assigns(:_not_authorized_caught)
    assert_redirected_to subject.forum
  end

  test 'should not put convert' do
    sign_in member

    put :convert, question_id: subject
    assert_not_nil assigns(:_not_authorized_caught)
    assert_redirected_to subject.forum
  end

  test 'should not get move' do
    sign_in member

    get :move, question_id: subject

    assert_not_nil assigns(:_not_authorized_caught)
    assert_redirected_to subject.forum
  end

  test 'should not put move' do
    sign_in member

    put :move, question_id: subject
    assert_not_nil assigns(:_not_authorized_caught)
    assert_redirected_to subject.forum
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(freetown) }
  let(:project) { create(:project, forum: freetown) }
  let(:project_moderator) { create_moderator(project) }

  test 'moderator should post create' do
    sign_in moderator

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           question: {
             title: 'Question',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:cq).resource
    assert_redirected_to question_url(assigns(:cq).resource)
  end

  test 'moderator should post create with project' do
    sign_in project_moderator

    assert_differences create_changes_array do
      post :create,
           project_id: project.id,
           question: {
             title: 'Question',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:cq).resource
    assert_equal project, assigns(:resource).project
    assert_redirected_to question_url(assigns(:cq).resource)
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(freetown) }
  let(:creator_question) { FactoryGirl.create(:question,
                                            creator: creator.profile,
                                            forum: freetown) }

  test 'creator should get edit' do
    sign_in creator

    get :edit, id: creator_question

    assert_response 200
    assert assigns(:resource)
  end

  test 'creator should put update' do
    sign_in creator

    put :update,
        id: creator_question,
        question: {
            title: 'new title',
            content: 'new contents'
        }

    assert_redirected_to question_path(creator_question)
    assert_equal 'new title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
  end

  test 'creator should render form for faulty put update' do
    sign_in creator

    put :update,
        id: creator_question,
        question: {
            title: 't',
            content: 'new contents'
        }

    assert_response 200
    assert assigns(:resource).changed?
  end


  ####################################
  # As Owner
  ####################################
  let(:page_question) { FactoryGirl.create(:question, forum: @freetown, creator: @freetown_owner.profile) }

  test 'owner should put update on page owner own question' do
    sign_in @freetown_owner
    @controller.instance_variable_set :@current_profile, @freetown.page.profile

    put :update,
        id: page_question,
        question: {
          title: 'New title',
          content: 'new contents'
        }

    assert_redirected_to question_url(page_question)
    assert_not_nil assigns(:resource)
    assert_equal 'New title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  # Currently only staffers can convert items
  test 'should get convert' do
    sign_in staff

    get :convert, question_id: subject
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put convert' do
    question = subject
    vote = FactoryGirl.create(:vote,
                              forum: freetown,
                              voteable: question)
    FactoryGirl.create(:activity,
                       forum: freetown,
                       trackable: question)

    sign_in staff

    put :convert!, question_id: subject, question: {f_convert: 'motions'}
    assert assigns(:result)
    assert_redirected_to assigns(:result)[:new]

    assert_equal Motion, assigns(:result)[:new].class
    assert assigns(:result)[:old].destroyed?

    # Test direct relations
    # assert_equal 0, assigns(:result)[:old].taggings.count
    # assert_equal 1, assigns(:result)[:new].taggings.count

    assert_equal 0, assigns(:result)[:old].votes.count
    assert_equal 1, assigns(:result)[:new].votes.count

    assert_equal 0, assigns(:result)[:old].activities.count
    assert_equal 1, assigns(:result)[:new].activities.count
  end


  # Currently only staffers can move items
  test 'should get move' do
    sign_in staff

    get :move, question_id: subject
    assert_response 200
  end

  let(:freetown_to) { FactoryGirl.create(:forum) }

  # Currently only staffers can convert items
  test 'should put move! without motions' do
    sign_in staff

    assert_differences [['freetown.reload.questions_count', -1],
                        ['freetown_to.reload.questions_count', 1]] do
      put :move!,
          question_id: subject,
          question: {
            forum_id: freetown_to.id
          }
    end
    assert_redirected_to assigns(:question)

    assert assigns(:question)
    assert_equal freetown_to, assigns(:question).forum
    forum_id = freetown_to.id
    assigns(:question).motions.pluck(:forum_id).each do |id|
      assert_equal freetown.id, id
    end
    assert assigns(:question).motions.blank?
    assigns(:question).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:question).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
  end

  test 'should put move! with motions' do
    sign_in staff

    assert_differences [['freetown.reload.questions_count', -1],
                        ['freetown_to.reload.questions_count', 1]] do
      put :move!,
          question_id: subject,
          question: {
            include_motions: '1',
            forum_id: freetown_to.id
          }
    end
    assert_redirected_to assigns(:question)

    assert assigns(:question)
    assert_equal freetown_to, assigns(:question).forum
    forum_id = freetown_to.id
    assigns(:question).motions.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert_equal 2, assigns(:question).motions.length
    assigns(:question).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:question).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end

  end

  private

  def create_changes_array
    [['Question.count', 1],
     ['Activity.count', 1],
     ['DirectNotificationsSchedulerWorker.new.collect_user_ids.count', 1],
     ['Notification.count', 1]]
  end
end

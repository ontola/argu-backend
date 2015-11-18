require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @holland, @holland_owner = create_forum_owner_pair({type: :populated_forum})
  end

  let(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }

  ####################################
  # As Guest
  ####################################
  test 'should get show when not logged in' do
    get :show, id: holland.questions.first
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:question_answers)

    assert holland.questions.first.motions.any?(&:is_trashed?), 'No trashed motions to test'
    assert_not assigns(:question_answers).any? { |qa| qa.is_trashed? }, 'Trashed motions are visible'
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show' do
    sign_in user

    get :show, id: holland.questions.first
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:question_answers)

    assert holland.questions.first.motions.any?(&:is_trashed?), 'No trashed motions to test'
    assert_not assigns(:question_answers).any? { |qa| qa.is_trashed? }, 'Trashed motions are visible'
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(holland) }
  let(:member_question) { FactoryGirl.create(:question, forum: holland, creator: member.profile) }

  test 'member should get new' do
    sign_in member

    get :new, forum_id: holland
    assert_response 200
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:forum)
  end

  test 'member should post create' do
    sign_in member

    assert_differences create_changes_array do
      post :create,
           forum_id: holland,
           question: {
             title: 'Question',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:cq).resource
    assert_not_nil assigns(:forum)
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

    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
    assert_redirected_to question_url(assigns(:question))
  end

  test 'should not put update on others question' do
    sign_in create_member(holland)

    put :update,
        id: member_question,
        question: {
          title: 'New title',
          content: 'new contents'
        }

    assert_equal member_question, assigns(:question)
  end

  test 'should not get convert' do
    sign_in member

    get :convert, question_id: holland.questions.first
    assert_redirected_to root_url
  end

  test 'should not put convert' do
    sign_in member

    put :convert, question_id: holland.questions.first
    assert_redirected_to root_url
  end

  test 'should not get move' do
    sign_in member

    get :move, question_id: holland.questions.first
    assert_redirected_to root_url
  end

  test 'should not put move' do
    sign_in member

    put :move, question_id: holland.questions.first
    assert_redirected_to root_url
  end


  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(holland) }
  let(:creator_question) { FactoryGirl.create(:question,
                                            creator: creator.profile,
                                            forum: holland) }

  test 'creator should get edit' do
    sign_in creator

    get :edit, id: creator_question

    assert_response 200
    assert assigns(:question)
    assert assigns(:forum)
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
    assert_equal 'new title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
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
    assert assigns(:question).changed?
  end


  ####################################
  # As Owner
  ####################################
  let(:page_question) { FactoryGirl.create(:question, forum: @holland, creator: @holland_owner.profile) }

  test 'owner should put update on page owner own question' do
    sign_in @holland_owner
    @controller.instance_variable_set :@current_profile, @holland.page.profile

    put :update,
        id: page_question,
        question: {
          title: 'New title',
          content: 'new contents'
        }

    assert_redirected_to question_url(page_question)
    assert_not_nil assigns(:question)
    assert_equal 'New title', assigns(:question).title
    assert_equal 'new contents', assigns(:question).content
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  # Currently only staffers can convert items
  test 'should get convert' do
    sign_in staff

    get :convert, question_id: holland.questions.first
    assert_response 200
  end

  # Currently only staffers can convert items
  test 'should put convert' do
    question = holland.questions.first
    vote = FactoryGirl.create(:vote,
                              forum: holland,
                              voteable: question)
    FactoryGirl.create(:activity,
                       forum: holland,
                       trackable: question)

    sign_in staff

    put :convert!, question_id: holland.questions.first, question: {f_convert: 'motions'}
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

    get :move, question_id: holland.questions.first
    assert_response 200
  end

  let(:freetown) { FactoryGirl.create(:forum) }

  # Currently only staffers can convert items
  test 'should put move!' do
    sign_in staff

    assert_differences [['holland.reload.questions_count', -1], ['freetown.reload.questions_count', 1]] do
      put :move!, question_id: holland.questions.first, question: { forum_id: freetown.id }
    end
    assert_redirected_to assigns(:question)

    assert assigns(:question)
    assert_equal freetown, assigns(:question).forum
    forum_id = freetown.id
    assigns(:question).motions.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assert assigns(:question).motions.blank?
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

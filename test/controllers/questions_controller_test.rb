require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown

  subject do
    create(:question,
           :with_motions,
           parent: freetown.edge)
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
        forum_id: freetown

    assert_not_a_user
    assert_response 302
  end

  test 'guest should not post create' do
    assert_no_difference 'Question.count' do
      post :create,
           forum_id: freetown,
           question: attributes_for(:question)
    end

    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

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
        forum_id: freetown

    assert_not_a_member
  end

  test 'user should not post create' do
    sign_in user

    assert_no_difference 'Question.count' do
      post :create,
           forum_id: freetown,
           question: attributes_for(:question)
    end

    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:member_question) { create(:question, parent: freetown.edge, creator: member.profile) }

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
             content: 'Contents',
             default_cover_photo_attributes: {
               image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
             }
           }
    end
    assert_not_nil assigns(:create_service).resource
    assert_equal 'cover_photo.jpg', assigns(:create_service).resource.default_cover_photo.image_identifier
    assert_equal 1, assigns(:create_service).resource.photos.count
    assert_redirected_to question_url(assigns(:create_service).resource)
  end

  test 'member should put update on own question' do
    sign_in member

    put :update,
        id: member_question,
        question: {
          title: 'New title',
          content: 'new contents',
          default_cover_photo_attributes: {
            image: fixture_file_upload('cover_photo.jpg', 'image/jpg')
          }
        }

    assert_not_nil assigns(:resource)
    assert_equal 'New title', assigns(:resource).title
    assert_equal 'new contents', assigns(:resource).content
    assert_equal 'cover_photo.jpg', assigns(:resource).default_cover_photo.image_identifier
    assert_equal 1, assigns(:resource).photos.reload.count
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

    assert_not_authorized
  end

  test 'should not get move' do
    sign_in member

    get :move, question_id: subject

    assert_not_authorized
    assert_redirected_to subject.forum
  end

  test 'should not put move' do
    sign_in member

    put :move, question_id: subject
    assert_not_authorized
    assert_redirected_to subject.forum
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(freetown) }
  let(:project) { create(:project, :with_follower, parent: freetown.edge) }
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
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to question_url(assigns(:create_service).resource)
  end

  test 'moderator should post create with project' do
    sign_in project_moderator

    assert_differences create_changes_array(2) do
      post :create,
           project_id: project.id,
           question: {
             title: 'Question',
             content: 'Contents'
           }
    end
    assert_not_nil assigns(:create_service).resource
    assert_equal project, assigns(:resource).project
    assert_redirected_to question_url(assigns(:create_service).resource)
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(freetown) }
  let(:creator_question) do
    create(:question,
           creator: creator.profile,
           parent: freetown.edge)
  end

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
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should delete trash' do
    sign_in manager
    subject

    assert_differences([['Question.trashed(false).count', -1],
                        ['Question.trashed_only.count', 1]]) do
      delete :trash,
             id: subject
    end

    assert_redirected_to freetown
  end

  test 'manager should delete destroy' do
    sign_in manager
    subject.trash
    assert_equal Motion.last.parent_model, subject

    assert_differences([['Question.trashed(false).count', 0],
                        ['Edge.count', -1],
                        ['Question.trashed(true).count', -1]]) do
      delete :destroy,
             id: subject
    end

    assert_equal Motion.last.parent_model, freetown
    assert_redirected_to freetown
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }
  let(:page_question) do
    create(:question,
           parent: freetown.edge,
           creator: owner.profile)
  end
  let(:owner_forum_question) { create(:question, parent: freetown.edge) }

  test 'owner should put update on page owner own question' do
    sign_in owner
    @controller.instance_variable_set :@current_profile, freetown.page.profile

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

  test 'owner should delete trash' do
    sign_in owner
    owner_forum_question # trigger

    assert_differences([['Question.trashed(false).count', -1],
                        ['Question.trashed_only.count', 1]]) do
      delete :trash,
             id: owner_forum_question
    end

    assert_redirected_to freetown
  end

  test 'owner should delete destroy' do
    sign_in owner
    owner_forum_question.trash

    assert_differences([['Question.trashed(false).count', 0],
                        ['Edge.count', -1],
                        ['Question.trashed(true).count', -1]]) do
      delete :destroy,
             id: owner_forum_question
    end

    assert_redirected_to freetown
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) {create(:user, :staff) }

  test 'staff should get edit' do
    sign_in staff

    get :edit, id: creator_question

    assert_response 200
    assert assigns(:resource)
  end

  # Currently only staffers can move items
  test 'should get move' do
    sign_in staff

    get :move, question_id: subject
    assert_response 200
  end

  let(:freetown_to) { create_forum }

  # Currently only staffers can move items
  test 'should put move! without motions' do
    sign_in staff
    subject

    assert_differences [['freetown.reload.questions.count', -1],
                        ['freetown_to.reload.questions.count', 1]] do
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
    assert assigns(:question).reload.motions.blank?
    assigns(:question).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:question).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
  end

  test 'should put move! with motions' do
    sign_in staff
    subject

    assert_differences [['freetown.reload.questions.count', -1],
                        ['freetown_to.reload.questions.count', 1]] do
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
    assert_equal 4, assigns(:question).motions.count
    assigns(:question).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:question).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
  end

  private

  def create_changes_array(notifications = 1)
    [['Question.count', 1],
     ['Edge.count', 1],
     ['Activity.count', 1],
     ['Notification.count', notifications]]
  end
end

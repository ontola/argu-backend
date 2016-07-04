require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown
  let(:question) do
    create(:question,
           :with_follower,
           parent: freetown.edge,
           options: {
            creator: create(:profile_direct_email)
           })
  end
  let(:subject) do
    create(:motion,
           :with_arguments,
           :with_group_responses,
           parent: question.edge)
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get show when not logged in' do
    general_show
  end

  test 'guest should not get edit when not logged in' do
    get :edit, id: subject
    assert_redirected_to new_user_session_path(r: edit_motion_path(subject))
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show' do
    general_show(user)
  end

  test 'user should get new' do
    general_new(user)
    assert_not_a_member
  end

  test 'user should not get move' do
    sign_in user
    get :move, motion_id: subject
    assert_redirected_to subject.forum
  end

  test 'user should not put move' do
    sign_in user
    put :move, motion_id: subject
    assert_redirected_to subject.forum
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:member_motion) { create(:motion, parent: freetown.edge, creator: member.profile) }

  test 'member should get new' do
    general_new(member, 200)
  end

  test 'member should post create' do
    general_create(member)
  end

  test 'member should post create with question' do
    general_create(
      member,
      attrs: attributes_for(:motion, parent: question.edge),
      changes: create_changes_array(2))
    assert_equal question, assigns(:create_service).resource.reload.question
  end

  test 'member should keep data on erroneous post create' do
    general_create(
      member,
      false,
      attrs: {
        title: 'Motion',
        content: 'C',
        parent: question.edge
      },
      changes: create_changes_array(0, 0))
    assert_not_nil assigns(:create_service).resource
    assert_response 200

    assert_select '[name=motion[title]]', 'Motion'
    assert_select '[name=motion[content]]', 'C'
    assert_select '[name=motion[question_id]]', question.id.to_s
  end

  test 'member should put update on own motion' do
    sign_in member

    put :update,
        id: member_motion,
        motion: {
          title: 'New title',
          content: 'new contents',
          default_cover_photo_attributes: {
            image: uploaded_file_object(Photo, :image, open_file('cover_photo.jpg'))
          }
        }

    assert_not_nil assigns(:update_service)
    assert_equal 'New title', assigns(:update_service).resource.title
    assert_equal 'new contents', assigns(:update_service).resource.content
    assert_equal 'cover_photo.jpg', assigns(:update_service).resource.default_cover_photo.image_identifier
    assert_equal 1, assigns(:update_service).resource.photos.count
    assert_redirected_to motion_url(assigns(:update_service).resource)
  end

  test 'member should not put update on others motion' do
    sign_in member

    put :update,
        id: subject,
        motion: {
          title: 'New title',
          content: 'new contents'
        }

    assert_redirected_to subject.forum
    assert_not_authorized
  end

  let(:no_create_without_question) do
    forum = create_forum
    create(:rule,
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
    user = create(:user, :follows_reactions_directly)
    create(:question,
           parent: no_create_without_question.edge,
           creator: user.profile)
  end
  let(:no_create_member) { create_member(no_create_without_question) }

  test 'member should not post create without create_without_question' do
    general_create(
      no_create_member,
      false,
      attrs: {parent: no_create_without_question.edge},
      changes: [['Motion.count', 0], ['Activity.count', 0]])

    assert_not_authorized
    assert_redirected_to no_create_without_question
  end

  test 'member should post create without create_without_question with question' do
    general_create(
      no_create_member,
      attrs: attributes_for(:motion, parent: no_create_question.edge),
      changes: create_changes_array)

    assert assigns(:create_service).resource.persisted?
    assert_equal no_create_question, assigns(:create_service).resource.question
  end

  ####################################
  # As Moderator
  ####################################
  let(:project) { create(:project, :with_follower, parent: freetown.edge) }
  let!(:project_question) do
    create(:question,
           :with_follower,
           parent: project.edge,
           project: project,
           creator: create(:profile_direct_email))
  end
  let(:moderator) { create_moderator(project) }

  test 'moderator should get new within project' do
    general_new(moderator, 200, parent: project.edge)
  end

  test 'moderator should post create within project' do
    sign_in moderator

    assert_differences create_changes_array(2) do
      post :create,
           project_id: project,
           motion: attributes_for(:motion)
    end
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource,
                                     start_motion_tour: true)
  end

  test 'moderator should post create within question within project' do
    sign_in moderator

    assert_differences create_changes_array(2) do
      post :create,
           question_id: project_question,
           motion: attributes_for(:motion)
    end
    assert_not_nil assigns(:create_service).resource
    assert_equal project, assigns(:create_service).resource.reload.project
    assert_equal project_question, assigns(:create_service).resource.reload.question
    assert_redirected_to motion_path(assigns(:create_service).resource,
                                     start_motion_tour: true)
  end

  ####################################
  # As Page
  ####################################
  let(:page) { create_member(freetown, create(:page)) }

  test 'page should post create' do
    sign_in page.owner.profileable
    change_actor page

    assert_differences create_changes_array do
      post :create,
           forum_id: freetown,
           motion: attributes_for(:motion)
    end
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource,
                                     start_motion_tour: true)
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(freetown) }
  let(:creator_motion) do
    create(:motion,
           creator: creator.profile,
           parent: freetown.edge)
  end

  test 'creator should get edit' do
    sign_in creator

    get :edit, id: creator_motion

    assert_response 200
    assert assigns(:motion)
  end

  test 'creator should put update' do
    sign_in creator

    put :update,
        id: creator_motion,
        motion: {
          title: 'New title',
          content: 'new contents'
        }

    assert_not_nil assigns(:update_service).resource
    assert_equal 'New title', assigns(:update_service).resource.title
    assert_equal 'new contents', assigns(:update_service).resource.content
    assert_redirected_to motion_url(assigns(:update_service).resource)
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
    assert assigns(:update_service).resource.changed?
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should delete trash' do
    sign_in manager
    subject # trigger

    assert_differences([['Motion.trashed(false).count', -1],
                        ['Motion.trashed_only.count', 1]]) do
      delete :trash,
             id: subject
    end

    assert_redirected_to question
  end

  test 'manager should delete destroy' do
    sign_in manager
    subject.trash

    # Remove the edges of the Motion and it's 6 Arguments
    assert_differences([['Motion.trashed(false).count', 0],
                        ['Edge.count', -7],
                        ['Motion.trashed(true).count', -1]]) do
      delete :destroy,
             id: subject
    end

    assert_redirected_to question
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { freetown.page.owner.profileable }

  test 'owner should delete trash' do
    sign_in owner
    subject # trigger

    assert_differences([['Motion.trashed(false).count', -1],
                        ['Motion.trashed_only.count', 1]]) do
      delete :trash,
             id: subject
    end

    assert_redirected_to question
  end

  test 'owner should delete destroy' do
    sign_in owner
    subject.trash

    # Remove the edges of the Motion and it's 6 Arguments
    assert_differences([['Motion.trashed(false).count', 0],
                        ['Edge.count', -7],
                        ['Motion.trashed(true).count', -1]]) do
      delete :destroy,
             id: subject
    end

    assert_redirected_to question
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  let(:forum_from) { create_forum }
  let(:forum_to) { create_forum }
  let(:motion_move) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: forum_from.edge)
  end

  test "staff should put update others' motion" do
    sign_in staff

    put :update,
        id: subject,
        motion: {
          title: 'New title',
          content: 'new contents'
        }

    updated_resource = assigns(:update_service).resource
    assert_equal subject.publisher_id, updated_resource.publisher_id
    assert_equal subject.creator_id, updated_resource.creator_id
    assert_equal 'New title', updated_resource.title
    assert_not_equal 'New title', subject.title
    assert_equal 'new contents', updated_resource.content
    assert_redirected_to motion_url(updated_resource)
  end

  # Currently only staffers can move items
  test 'staff should get move' do
    sign_in staff

    get :move, motion_id: subject
    assert_response 200
  end

  # Currently only staffers can move items
  test 'staff should put move!' do
    sign_in staff
    motion_move

    assert_differences [['forum_from.reload.motions.count', -1],
                        ['forum_to.reload.motions.count', 1]] do
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
    assert assigns(:motion).question.blank?
    assert assigns(:motion).activities.count > 0
    assigns(:motion).activities.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
    assigns(:motion).taggings.pluck(:forum_id).each do |id|
      assert_equal forum_id, id
    end
  end

  private

  # Detect the changes that should go hand in hand with object creation
  # @param notifications [Integer] Amount of notifications to be created
  def create_changes_array(notifications = 1, count = 1)
    c = [['Motion.count', count],
         ['Edge.count', count],
         ['Activity.count', count],
         ['Notification.count', notifications]]
    c
  end

  def general_create(role = nil,
                     should = true,
                     attrs: attributes_for(:motion, parent: freetown.edge),
                     changes: create_changes_array)
    sign_in role if role

    assert_differences changes do
      post :create,
           attrs[:parent].owner_type.foreign_key => attrs[:parent].owner_id,
           motion: attrs
    end
    if should
      assert_not_nil assigns(:create_service).resource
      assert_redirected_to motion_path(assigns(:create_service).resource, start_motion_tour: true)
    end
  end

  def general_new(role = nil, response = 302, params = {parent: freetown.edge})
    sign_in role if role
    get :new, params[:parent].owner_type.foreign_key => params[:parent].owner_id
  end

  def general_show(role = nil, should = true)
    sign_in role if role
    get :show, id: subject

    if should
      assert_response 200
      assert_not_nil assigns(:motion)
      assert_not_nil assigns(:vote)

      assert subject.arguments.where(is_trashed: true).count > 0,
             'No trashed arguments to test on'
      assert_not assigns(:arguments).any? { |arr| arr[1][:collection].any?(&:is_trashed?) },
                 'Trashed arguments are visible'
      assert assigns(:group_responses).keys.all?(&:discussion?),
             'Non discussion groups are shown under motions'
    end
  end
end

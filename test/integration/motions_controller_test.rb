require 'test_helper'

class MotionsControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:question) do
    create(:question,
           :with_follower,
           parent: freetown.edge,
           options: {
            creator: create(:profile_direct_email)
           })
  end
  let(:closed_question) do
    create(:question,
           :with_follower,
           expires_at: 1.day.ago,
           parent: freetown.edge,
           creator: create(:profile_direct_email))
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
    get edit_motion_path(subject)
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
    get motion_move_path(subject)
    assert_redirected_to subject.forum
  end

  test 'user should not put move' do
    sign_in user
    put motion_move_path(subject)
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

  test 'member should show tutorial only on first post create' do
    general_create(member)
    general_create(member, false)
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource)
  end

  test 'member should post create with question' do
    general_create(
      member,
      attrs: attributes_for(:motion, parent: question.edge),
      changes: create_changes_array(2))
    assert_equal question, assigns(:create_service).resource.reload.question
  end

  test 'member should not post create with closed question' do
    general_create(
      member,
      false,
      attrs: attributes_for(:motion, parent: closed_question.edge),
      changes: [])
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

    assert_select '#motion_title', 'Motion'
    assert_select '#motion_content', 'C'
    assert_select '#motion_question_id[value=?]', question.id.to_s
  end

  test 'member should put update on own motion' do
    general_update(member_motion, member, attrs: {
      title: 'New title',
      content: 'new contents',
      default_cover_photo_attributes: {
        image: fixture_file_upload('test/fixtures/cover_photo.jpg', 'image/jpg')
      }
    })
    assert_equal 'cover_photo.jpg',
                 assigns(:update_service).resource.default_cover_photo.image_identifier
    assert_equal 1, assigns(:update_service).resource.photos.count
  end

  test 'member should not put update on others motion' do
    general_update(subject, member, false)

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
      post project_motions_path(project),
           params: {motion: attributes_for(:motion)}
    end
    assert_not_nil assigns(:create_service).resource
    assert_redirected_to motion_path(assigns(:create_service).resource,
                                     start_motion_tour: true)
  end

  test 'moderator should post create within question within project' do
    sign_in moderator

    assert_differences create_changes_array(2) do
      post question_motions_path(project_question),
           params: {motion: attributes_for(:motion)}
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
      post forum_motions_path(freetown),
           params: {motion: attributes_for(:motion)}
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

    get edit_motion_path(creator_motion)

    assert_response 200
    assert assigns(:motion)
  end

  test 'creator should put update' do
    general_update(creator_motion, creator)
  end

  test 'creator should render form for faulty put update' do
    general_update(creator_motion, creator, false, attrs: {title: 't', content: 'new contents'})

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
      delete motion_path(subject)
    end

    assert_redirected_to question
  end

  test 'manager should delete destroy' do
    sign_in manager
    subject.trash

    # Remove the edges of the Motion, its Decision and its 6 Arguments
    assert_differences([['Motion.trashed(false).count', 0],
                        ['Edge.count', -8],
                        ['Motion.trashed(true).count', -1]]) do
      delete motion_path(subject, destroy: 'true')
    end

    assert_redirected_to question
  end

  ####################################
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test 'owner should delete trash' do
    sign_in owner
    subject # trigger

    assert_differences([['Motion.trashed(false).count', -1],
                        ['Motion.trashed_only.count', 1]]) do
      delete motion_path(subject)
    end

    assert_redirected_to question
  end

  test 'owner should delete destroy' do
    sign_in owner
    subject.trash

    # Remove the edges of the Motion, its Decision and its 6 Arguments
    assert_differences([['Motion.trashed(false).count', 0],
                        ['Edge.count', -8],
                        ['Motion.trashed(true).count', -1]]) do
      delete motion_path(subject, destroy: 'true')
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

  test 'staff should get edit' do
    sign_in staff

    get edit_motion_path(creator_motion)

    assert_response 200
    assert assigns(:motion)
  end

  test "staff should put update others' motion" do
    general_update(subject, staff)

    updated_resource = assigns(:update_service).resource
    assert_equal subject.publisher_id, updated_resource.publisher_id
    assert_equal subject.creator_id, updated_resource.creator_id
  end

  # Currently only staffers can move items
  test 'staff should get move' do
    sign_in staff

    get motion_move_path(motion_id: subject)
    assert_response 200
  end

  # Currently only staffers can move items
  test 'staff should put move!' do
    sign_in staff
    motion_move

    assert_differences [['forum_from.reload.motions.count', -1],
                        ['forum_to.reload.motions.count', 1]] do
      put motion_move_path(motion_move),
          params: {motion: {forum_id: forum_to.id}}
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
         ['Edge.count', count * 2],
         ['Decision.count', count],
         ['Activity.count', count],
         ['Notification.count', notifications]]
    c
  end

  def general_create(role = nil,
                     should = true,
                     attrs: attributes_for(:motion, parent: freetown.edge),
                     changes: create_changes_array)
    sign_in role if role
    path = case attrs[:parent].owner
           when Question
             question_motions_path(attrs[:parent].owner)
           else
             forum_motions_path(attrs[:parent].owner)
           end

    assert_differences changes do
      post path,
           params: {motion: attrs}
    end
    if should
      assert_not_nil assigns(:create_service).resource
      assert_analytics_collected('motions', 'create')
      assert_redirected_to motion_path(assigns(:create_service).resource, start_motion_tour: true)
    end
  end

  def general_update(motion,
                     role = nil,
                     should = true,
                     attrs: {title: 'New title', content: 'new contents'},
                     changes: create_changes_array)
    sign_in role if role

    put motion_path(motion), params: {motion: attrs}

    if should
      assert_not_nil assigns(:update_service).resource
      assert_equal attrs[:title], assigns(:update_service).resource.title if attrs[:title].present?
      if attrs[:content].present?
        assert_equal attrs[:content], assigns(:update_service).resource.content
      end
      assert_redirected_to motion_path(assigns(:update_service).resource)
    end
  end

  def general_new(role = nil, response = 302, params = {parent: freetown.edge})
    sign_in role if role
    case params[:parent].owner
    when Question
      get new_question_motion_path(params[:parent].owner)
    when Project
      get new_project_motion_path(params[:parent].owner)
    else
      get new_forum_motion_path(params[:parent].owner)
    end
  end

  def general_show(role = nil, should = true)
    sign_in role if role
    get motion_path(subject)

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

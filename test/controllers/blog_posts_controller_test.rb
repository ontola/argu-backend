require 'test_helper'

class BlogPostsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  define_freetown
  let!(:page) { argu }
  let!(:owner) { page.owner.profileable }
  let(:project) { create(:project, argu_publication: build(:publication), parent: freetown.edge) }
  let!(:moderator) { create_member(freetown) }
  let!(:subject) do
    create(:blog_post,
           argu_publication: build(:publication),
           happened_at: DateTime.current,
           parent: project.edge)
  end
  let!(:trashed_subject) do
    create(:blog_post,
           argu_publication: build(:publication),
           happened_at: DateTime.current,
           trashed_at: Time.current,
           parent: project.edge)
  end
  let(:unpublished) { create(:blog_post, parent: project.edge) }

  ####################################
  # Guest, User, Member share features
  ####################################

  def general_new(response = 302)
    get :new,
        project_id: project

    assert_response response
  end

  def general_show(response = 200, record = subject)
    get :show,
        id: record

    assert_response response
  end

  def general_create_draft(response = 302, differences = [['BlogPost.count', 0],
                                                          ['Edge.count', 0],
                                                          ['Activity.loggings.count', 0]])
    assert_differences(differences) do
      post :create,
           project_id: project,
           blog_post: attributes_for(:blog_post,
                                     parent: project.edge,
                                     happened_at: DateTime.now,
                                     argu_publication_attributes: {publish_type: :draft})
    end

    assert_response response
  end

  def general_create_publish(response = 302, differences = [['BlogPost.count', 0],
                                                            ['Edge.count', 0],
                                                            ['Activity.loggings.count', 0]])
    assert_differences(differences) do
      post :create,
           project_id: project,
           blog_post: attributes_for(:blog_post,
                                     parent: project.edge,
                                     happened_at: DateTime.now,
                                     argu_publication_attributes: {publish_type: :direct})

      Sidekiq::Testing.inline! do
        Publication.last.send(:reset)
      end
    end

    assert_response response
  end

  def general_edit(response = 302)
    get :edit,
        id: subject

    assert_response response
  end

  def general_update(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)

    assert_difference('Activity.count', changed ? 1 : 0) do
      patch :update,
            id: subject,
            blog_post: attributes_for(:blog_post, parent: project.edge)
    end

    assert_response response
    if assigns(:update_service).try(:resource).present?
      ch_method.call subject
                       .updated_at
                       .utc
                       .iso8601(6),
                     assigns(:update_service)
                       .try(:resource)
                       .try(:updated_at)
                       .try(:utc)
                       .try(:iso8601, 6)
    else
      assert false, 'Model changed when it should not have' if changed
    end
  end

  def general_trash(response = 302, difference = 0)
    assert_differences([['BlogPost.trashed_only.count', difference], ['Activity.loggings.count', difference.abs]]) do
      delete :trash,
             id: subject
    end

    assert_response response
  end

  def general_destroy(response = 302, difference = 0)
    assert_differences(
      [['BlogPost.count', difference],
       ['Edge.count', difference],
       ['Activity.loggings.count', difference.abs]]) do
      delete :destroy,
             id: trashed_subject
    end

    assert_response response
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should not get new' do
    general_new
  end

  test 'guest should get show published' do
    general_show
  end

  test 'guest should not get show unpublished' do
    general_show 302, unpublished
    assert_not_authorized
  end

  test 'guest should not post create' do
    general_create_draft
  end

  test 'guest should not get edit' do
    general_edit
  end

  test 'guest should not patch update' do
    general_update
  end

  test 'guest should not delete destroy trash' do
    general_trash
    assert_not_a_user
  end

  test 'guest should not delete destroy' do
    general_destroy
    assert_not_a_user
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user
    general_new 403
    assert_not_a_member
  end

  test 'user should get show' do
    sign_in user
    general_show
  end

  test 'user should not post create' do
    sign_in user
    general_create_draft 403
    assert_not_a_member
  end

  test 'user should not get edit' do
    sign_in user
    general_edit 403
    assert_not_a_member
  end

  test 'user should not patch update' do
    sign_in user
    general_update 403
    assert_not_a_member
  end

  test 'user should not delete destroy trash' do
    sign_in user
    general_trash 403
    assert_not_a_member
  end

  test 'user should not delete destroy' do
    sign_in user
    general_destroy 403
    assert_not_a_member
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not get new' do
    sign_in member
    general_new
  end

  test 'member should get show' do
    sign_in member
    general_show
  end

  test 'member should not post create' do
    sign_in member
    general_create_draft
  end

  test 'member should not get edit' do
    sign_in member
    general_edit
  end

  test 'member should not patch update' do
    sign_in member
    general_update
  end

  test 'member should not delete destroy trash' do
    sign_in member
    general_trash
  end

  test 'member should not delete destroy' do
    sign_in member
    general_destroy
  end

  ####################################
  # As Owner
  ####################################

  test 'owner should get new' do
    sign_in owner
    general_new 200
  end

  test 'owner should get show' do
    sign_in owner
    general_show
  end

  test 'owner should post create draft' do
    sign_in owner
    general_create_draft 302,
                         [['BlogPost.count', 1],
                          ['Edge.count', 1],
                          ['BlogPost.published.count', 0]]
  end

  test 'owner should post create publish' do
    sign_in owner
    general_create_publish 302,
                           [['BlogPost.count', 1],
                            ['Edge.count', 1],
                            ['BlogPost.published.count', 1]]
  end

  test 'owner should get edit' do
    sign_in owner
    general_edit 200
  end

  test 'owner should patch update' do
    sign_in owner
    general_update 302, true
  end

  test 'owner should delete destroy trash' do
    sign_in owner
    general_trash 302, 1
  end

  test 'owner should delete destroy' do
    sign_in owner
    general_destroy 302, -1
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager freetown }
  test 'manager should get new' do
    sign_in manager
    general_new 200
  end

  test 'manager should get show' do
    sign_in manager
    general_show 200
  end

  test 'manager should post create draft' do
    sign_in manager
    general_create_draft 302,
                         [['BlogPost.count', 1],
                          ['Edge.count', 1],
                          ['BlogPost.published.count', 0]]
  end

  test 'manager should post create publish' do
    sign_in manager
    general_create_publish 302,
                           [['BlogPost.count', 1],
                            ['Edge.count', 1],
                            ['BlogPost.published.count', 1]]
  end

  test 'manager should get edit' do
    sign_in manager
    general_edit 200
  end

  test 'manager should patch update' do
    sign_in manager
    general_update 302, true
  end

  test 'manager should delete destroy trash' do
    sign_in manager
    general_trash 302, 1
  end

  test 'manager should delete destroy' do
    sign_in manager
    general_destroy 302, -1
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get new' do
    sign_in staff
    general_new 200
  end

  test 'staff should get show' do
    sign_in staff
    general_show 200
  end

  test 'staff should post create draft' do
    sign_in staff
    general_create_draft 302,
                         [['BlogPost.count', 1],
                          ['Edge.count', 1],
                          ['BlogPost.published.count', 0]]
  end

  test 'staff should post create publish' do
    sign_in staff
    general_create_publish 302,
                           [['BlogPost.count', 1],
                            ['Edge.count', 1],
                            ['BlogPost.published.count', 1]]
  end

  test 'staff should get edit' do
    sign_in staff
    general_edit 200
  end

  test 'staff should patch update' do
    sign_in staff
    general_update 302, true
  end

  test 'staff should delete destroy trash' do
    sign_in staff
    general_trash 302, 1
  end

  test 'staff should delete destroy' do
    sign_in staff
    general_destroy 302, -1
  end
end

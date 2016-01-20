require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:owner) { FactoryGirl.create(:user) }
  let!(:page) { FactoryGirl.create(:page, owner: owner.profile) }
  let!(:freetown) { FactoryGirl.create(:forum, :with_follower, page: page, name: 'freetown') }
  let!(:moderator) { create_member(freetown) }
  let!(:subject) do
    FactoryGirl.create(:project,
                       :published,
                       forum: freetown)
  end
  let(:unpublished) { create(:project, :unpublished, forum: freetown) }


  ####################################
  # Guest, User, Member share features
  ####################################

  def general_new(response = 302)
    get :new,
        forum_id: freetown

    assert_response response
  end

  def general_show(response = 200, record = subject)
    get :show,
        id: record

    assert_response response
  end

  def general_create(response = 302, differences = [['Project.count', 0],
                                                    ['Stepup.count', 0],
                                                    ['Phase.count', 0]])
    assert_differences(differences) do
      post :create,
           forum_id: freetown,
           project: attributes_for(:project,
                                   stepups_attributes: {'12321' => {moderator: moderator.url}},
                                   phases_attributes: {'12321' => attributes_for(:phase)})
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

    patch :update,
          id: subject,
          project: attributes_for(:project)

    assert_response response
    if assigns(:up).try(:resource).present?
      ch_method.call subject
                       .updated_at
                       .iso8601(6),
                     assigns(:up)
                       .try(:resource)
                       .try(:updated_at)
                       .try(:iso8601, 6)
    else
      assert false, "can't be changed" if changed
    end
  end

  def general_destroy(response = 302, difference = 0)
    assert_difference('Project.trashed.count', difference) do
      delete :destroy,
             id: subject
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
    assert assigns(:_not_authorized_caught)
  end

  test 'guest should not post create' do
    general_create
  end

  test 'guest should not get edit' do
    general_edit
  end

  test 'guest should not patch update' do
    general_update
  end

  test 'guest should not delete destroy' do
    general_destroy
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get new' do
    sign_in user
    general_new 200
    assert_equal true, assigns(:_not_a_member_caught)
  end

  test 'user should get show' do
    sign_in user
    general_show
  end

  test 'user should not post create' do
    sign_in user
    general_create 200
    assert_equal true, assigns(:_not_a_member_caught)
  end

  test 'user should not get edit' do
    sign_in user
    general_edit 200
    assert_equal true, assigns(:_not_a_member_caught)
  end

  test 'user should not patch update' do
    sign_in user
    general_update 200
    assert_equal true, assigns(:_not_a_member_caught)
  end

  test 'user should not delete destroy' do
    sign_in user
    general_destroy 200
    assert_equal true, assigns(:_not_a_member_caught)
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
    general_create
  end

  test 'member should not get edit' do
    sign_in member
    general_edit
  end

  test 'member should not patch update' do
    sign_in member
    general_update
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

  test 'owner should post create' do
    sign_in owner
    general_create 302,
                   [['Project.count', 1],
                    ['Stepup.count', 1],
                    ['Phase.count', 1]]
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

  test 'manager should post create' do
    sign_in manager
    general_create 302,
                   [['Project.count', 1],
                    ['Stepup.count', 1],
                    ['Phase.count', 1]]
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

  test 'staff should post create' do
    sign_in staff
    general_create 302,
                   [['Project.count', 1],
                    ['Stepup.count', 1],
                    ['Phase.count', 1]]
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
    general_destroy 302, -1
  end

  test 'staff should delete destroy' do
    sign_in staff
    general_destroy 302, -1
  end

end

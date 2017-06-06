# frozen_string_literal: true
require 'test_helper'

class PhasesControllerTest < ActionController::TestCase
  define_freetown
  let!(:page) { argu }
  let!(:super_admin) { create_super_admin(freetown) }
  let!(:project) { create(:project, parent: freetown.edge) }
  let!(:unpublished_project) do
    create(:project,
           parent: freetown.edge,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let(:subject) { create(:phase, parent: project.edge) }
  let(:unpublished_subject) { create(:phase, parent: unpublished_project.edge) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get show published' do
    general_show
  end

  test 'guest should not get show unpublished' do
    general_show_unpublished 403
  end

  test 'guest should not get edit' do
    general_edit
  end

  test 'guest should not patch update' do
    general_update
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show published' do
    sign_in user
    general_show
  end

  test 'user should not get show unpublished' do
    sign_in user
    general_show_unpublished 403
  end

  test 'user should not get edit' do
    sign_in user
    general_edit 403
    assert_not_authorized
  end

  test 'user should not patch update' do
    sign_in user
    general_update 403
    assert_not_authorized
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should get show published' do
    sign_in member
    general_show
  end

  test 'member should not get show unpublished' do
    sign_in member
    general_show_unpublished 403
  end

  test 'member should not get edit' do
    sign_in member
    general_edit 403
  end

  test 'member should not patch update' do
    sign_in member
    general_update 403
  end

  ####################################
  # As Admin
  ####################################

  test 'super_admin should get show published' do
    sign_in super_admin
    general_show
  end

  test 'super_admin should get show unpublished' do
    sign_in super_admin
    general_show_unpublished 200
  end

  test 'super_admin should get edit' do
    sign_in super_admin
    general_edit 200
  end

  test 'super_admin should patch update' do
    sign_in super_admin
    general_update 302, true
  end

  test 'super_admin should patch update finish' do
    sign_in super_admin
    general_finish 302, true
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager freetown }

  test 'manager should get show published' do
    sign_in manager
    general_show 200
  end

  test 'manager should get show unpublished' do
    sign_in manager
    general_show_unpublished 200
  end

  test 'manager should get edit' do
    sign_in manager
    general_edit 200
  end

  test 'manager should patch update' do
    sign_in manager
    general_update 302, true
  end

  test 'manager should patch update finish' do
    sign_in manager
    general_finish 302, true
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get show published' do
    sign_in staff
    general_show 200
  end

  test 'staff should get show unpublished' do
    sign_in staff
    general_show_unpublished 200
  end

  test 'staff should get edit' do
    sign_in staff
    general_edit 200
  end

  test 'staff should patch update' do
    sign_in staff
    general_update 302, true
  end

  test 'staff should patch update finish' do
    sign_in staff
    general_finish 302, true
  end

  private

  ####################################
  # Guest, User, Member share features
  ####################################

  def general_show(response = 200, record = subject)
    get :show,
        params: {id: record}

    assert_response response
  end

  def general_show_unpublished(response = 302, record = unpublished_subject)
    get :show,
        params: {id: record}

    assert_response response
  end

  def general_edit(response = 302)
    get :edit,
        params: {id: subject}

    assert_response response
  end

  def general_update(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)

    patch :update,
          params: {
            id: subject,
            phase: attributes_for(:phase)
          }

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
    elsif changed
      assert false, 'Model changed when it should not have'
    end
  end

  def general_finish(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)

    patch :update,
          params: {
            id: subject,
            phase: attributes_for(:phase).merge(finish_phase: 'true')
          }

    assert_response response
    if assigns(:update_service).try(:resource).present?
      ch_method.call subject
        .end_date,
                     assigns(:update_service)
        .try(:resource)
        .try(:end_date)
    elsif changed
      assert false, 'Model changed when it should not have'
    end
  end
end

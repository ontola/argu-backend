# frozen_string_literal: true

require 'test_helper'

class DraftsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let!(:motion) do
    create(:motion,
           parent: freetown.edge,
           publisher: user,
           edge_attributes: {argu_publication_attributes: {draft: true}})
  end
  let!(:page_motion) do
    create(:motion,
           parent: freetown.edge,
           creator: freetown.page.profile,
           edge_attributes: {argu_publication_attributes: {draft: true}})
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get index' do
    get drafts_user_path(user)
    assert_not_authorized
    assert_response 403
    assert_select '.draft', 0
  end

  ####################################
  # As User
  ####################################
  let(:other_user) { create(:user) }

  test 'user should not get index other' do
    sign_in other_user
    get drafts_user_path(user)
    assert_not_authorized
    assert_response 403
    assert_select '.draft', 0
  end

  test 'user should get index' do
    sign_in user
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 1
  end

  ####################################
  # As manager
  ####################################
  test 'manager should get index' do
    create(:group_membership,
           parent: create(
             :grant,
             edge: freetown.page.edge,
             group: create(:group, parent: freetown.page.edge),
             role: Grant.roles['manager']
           ).group,
           shortname: user.url)
    sign_in user
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 2
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get index' do
    sign_in staff
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 1
  end
end

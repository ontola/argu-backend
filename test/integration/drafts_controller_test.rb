# frozen_string_literal: true
require 'test_helper'

class DraftsControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get index' do
    get drafts_user_path(user)
    assert_not_authorized
    assert_response 403
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
  end

  test 'user should get index' do
    sign_in user
    get drafts_user_path(user)
    assert 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get index' do
    sign_in staff
    get drafts_user_path(user)
    assert 200
  end
end

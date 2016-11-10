# frozen_string_literal: true
require 'test_helper'

class VoteEventsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get show' do
    get vote_event_path(motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As User
  ####################################
  test 'user should get show' do
    sign_in
    get vote_event_path(motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should get show' do
    sign_in member
    get vote_event_path(motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As super_admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  test 'super_admin should get show' do
    sign_in super_admin
    get vote_event_path(motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get show' do
    sign_in staff
    get vote_event_path(motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end
end

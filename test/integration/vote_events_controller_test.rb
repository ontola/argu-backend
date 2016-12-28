# frozen_string_literal: true
require 'test_helper'

class VoteEventsControllerTest < ActionDispatch::IntegrationTest
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
  # As Owner
  ####################################
  let(:owner) { create_owner(freetown) }

  test 'owner should get show' do
    sign_in owner
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

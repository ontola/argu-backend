# frozen_string_literal: true

require 'test_helper'

class VoteEventsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get show' do
    get motion_vote_event_path(motion, motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As User
  ####################################
  test 'user should get show' do
    sign_in
    get motion_vote_event_path(motion, motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(freetown) }

  test 'initiator should get show' do
    sign_in initiator
    get motion_vote_event_path(motion, motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should get show' do
    sign_in administrator
    get motion_vote_event_path(motion, motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get show' do
    sign_in staff
    get motion_vote_event_path(motion, motion.default_vote_event, params: {format: :json_api})
    assert_response 200
  end
end

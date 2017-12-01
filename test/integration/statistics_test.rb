# frozen_string_literal: true

require 'test_helper'

class StatisticsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get statistics of forum' do
    get edge_statistics_path(freetown.edge)
    assert_not_authorized
  end

  test 'guest should not get statistics of motion' do
    get edge_statistics_path(motion.edge)
    assert_not_authorized
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get statistics of forum' do
    sign_in user
    get edge_statistics_path(freetown.edge)
    assert_not_authorized
  end

  test 'user should not get statistics of motion' do
    sign_in user
    get edge_statistics_path(motion.edge)
    assert_not_authorized
  end

  ####################################
  # As administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should not get statistics of forum' do
    sign_in administrator
    get edge_statistics_path(freetown.edge)
    assert_response 200
  end

  test 'administrator should not get statistics of motion' do
    sign_in administrator
    get edge_statistics_path(motion.edge)
    assert_response 200
  end

  ####################################
  # As staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not get statistics of forum' do
    sign_in staff
    get edge_statistics_path(freetown.edge)
    assert_response 200
  end

  test 'staff should not get statistics of motion' do
    sign_in staff
    get edge_statistics_path(motion.edge)
    assert_response 200
  end
end

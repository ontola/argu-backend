# frozen_string_literal: true

require 'test_helper'

class StatisticsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }

  ####################################
  # As Guest
  ####################################
  test 'guest should not get statistics of forum' do
    get expand_uri_template(:statistics_iri, parent_iri: freetown.canonical_iri_path)
    assert_not_authorized
  end

  test 'guest should not get statistics of motion' do
    get expand_uri_template(:statistics_iri, parent_iri: motion.canonical_iri_path)
    assert_not_authorized
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get statistics of forum' do
    sign_in user
    get expand_uri_template(:statistics_iri, parent_iri: freetown.canonical_iri_path)
    assert_not_authorized
  end

  test 'user should not get statistics of motion' do
    sign_in user
    get expand_uri_template(:statistics_iri, parent_iri: motion.canonical_iri_path)
    assert_not_authorized
  end

  ####################################
  # As administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should not get statistics of forum' do
    sign_in administrator
    get expand_uri_template(:statistics_iri, parent_iri: freetown.canonical_iri_path)
    assert_response 200
  end

  test 'administrator should not get statistics of motion' do
    sign_in administrator
    get expand_uri_template(:statistics_iri, parent_iri: motion.canonical_iri_path)
    assert_response 200
  end

  test 'administrator should not get statistics of forum n3' do
    sign_in administrator
    get expand_uri_template(:statistics_iri, parent_iri: freetown.canonical_iri_path),
        headers: argu_headers(accept: :n3)
    assert_response 200
  end

  test 'administrator should not get statistics of motion n3' do
    sign_in administrator
    get expand_uri_template(:statistics_iri, parent_iri: motion.canonical_iri_path), headers: argu_headers(accept: :n3)
    assert_response 200
  end

  ####################################
  # As staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not get statistics of forum' do
    sign_in staff
    get expand_uri_template(:statistics_iri, parent_iri: freetown.canonical_iri_path)
    assert_response 200
  end

  test 'staff should not get statistics of motion' do
    sign_in staff
    get expand_uri_template(:statistics_iri, parent_iri: motion.canonical_iri_path)
    assert_response 200
  end
end

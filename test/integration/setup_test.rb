# frozen_string_literal: true

require 'test_helper'

class SetupTest < ActionDispatch::IntegrationTest
  include TestHelper

  define_freetown
  let(:user) { create(:user) }
  let(:user_no_shortname) { create(:user, :no_shortname, first_name: nil, last_name: nil) }
  let(:guest_user) { create_guest_user }

  ####################################
  # As Guest
  ####################################
  test 'guest should get setup' do
    sign_in guest_user
    get iri_from_template(:setup_iri, root: argu)
    assert_response 200
    expect_ontola_action(redirect: argu.iri, reload: true)
  end

  ####################################
  # As User without shortname
  ####################################
  test 'user without shortname should get setup' do
    sign_in user_no_shortname
    get iri_from_template(:setup_iri, root: argu)
    assert_response 200
    expect_ontola_action_count(0)
  end

  ####################################
  # As User with shortname
  ####################################
  test 'user should get setup' do
    sign_in user
    get iri_from_template(:setup_iri, root: argu)
    assert_response 200
    expect_ontola_action(redirect: argu.iri, reload: true)
  end
end

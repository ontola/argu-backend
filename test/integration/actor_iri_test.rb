# frozen_string_literal: true

require 'test_helper'

class ActorIRITest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should post create as self' do
    sign_in user

    post_motion(true)
  end

  test 'user should not post create as page' do
    sign_in user

    post_motion(false, freetown.page.iri)
  end

  ####################################
  # As Unconfirmed Administrator
  ####################################
  let(:unconfirmed_administrator) { create_administrator(freetown, create(:user, :unconfirmed)) }

  test 'unconfirmed administrator should not post create as page' do
    sign_in unconfirmed_administrator

    post_motion(false, freetown.page.iri)
  end

  ####################################
  # As Super Admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should post create as page' do
    sign_in administrator

    post_motion(true, freetown.page.iri)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should post create as page' do
    sign_in staff

    post_motion(true, freetown.page.iri)
  end

  private

  def post_motion(should, iri = nil)
    assert_difference('Motion.count', should ? 1 : 0) do
      post forum_motions_path(freetown),
           params: {
             actor_iri: iri,
             motion: attributes_for(:motion)
           }
    end
    should ? assert_response(302) : assert_not_authorized
  end
end

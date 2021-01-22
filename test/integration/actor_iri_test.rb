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

    post_motion(true, user)
  end

  test 'user should not post create as page' do
    sign_in user

    post_motion(true, user, argu.iri)
  end

  ####################################
  # As Unconfirmed Administrator
  ####################################
  let(:unconfirmed_administrator) { create_administrator(freetown, create(:unconfirmed_user)) }

  test 'unconfirmed administrator should not post create as page' do
    sign_in unconfirmed_administrator

    post_motion(true, unconfirmed_administrator, argu.iri)
  end

  ####################################
  # As Super Admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should post create as page' do
    sign_in administrator

    post_motion(true, argu, argu.iri)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should post create as page' do
    sign_in staff

    post_motion(true, argu, argu.iri)
  end

  private

  def post_motion(should, expected_actor = nil, actor = nil)
    assert_difference('Motion.count', should ? 1 : 0) do
      post collection_iri(freetown, :motions),
           params: {
             actor_iri: actor,
             motion: attributes_for(:motion)
           }
    end
    should ? assert_response(:created) : assert_not_authorized
    assert_equal(expected_actor.profile, Motion.last.creator) if should
  end
end

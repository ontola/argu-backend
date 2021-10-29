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

  test 'unconfirmed administrator should not post create' do
    sign_in unconfirmed_administrator

    post_motion(false, unconfirmed_administrator, nil, :unprocessable_entity)
  end

  test 'unconfirmed administrator should not post create as page' do
    sign_in unconfirmed_administrator

    post_motion(false, unconfirmed_administrator, nil, :unprocessable_entity)
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

  def post_motion(should, expected_actor = nil, actor = nil, status = nil)
    assert_difference('Motion.count', should ? 1 : 0) do
      post freetown.collection_iri(:motions),
           params: {
             actor_iri: actor,
             motion: attributes_for(:motion)
           }
    end
    assert_response(status || (should ? :created : :forbidden))
    assert_equal(expected_actor.profile, Motion.last.creator) if should
  end
end

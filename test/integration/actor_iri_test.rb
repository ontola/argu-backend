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

    post_motion(false, freetown.page.context_id)
  end

  ####################################
  # As Unconfirmed Super Admin
  ####################################
  let(:unconfirmed_super_admin) { create_super_admin(freetown, create(:user, :unconfirmed)) }

  test 'unconfirmed super admin should not post create as page' do
    sign_in unconfirmed_super_admin

    post_motion(false, freetown.page.context_id)
  end

  ####################################
  # As Super Admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  test 'super admin should post create as page' do
    sign_in super_admin

    post_motion(true, freetown.page.context_id)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not post create as page' do
    sign_in staff

    post_motion(false, freetown.page.context_id)
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

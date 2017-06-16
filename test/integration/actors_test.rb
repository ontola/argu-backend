# frozen_string_literal: true
require 'test_helper'

class ActorsTest < ActionDispatch::IntegrationTest
  define_freetown

  ####################################
  # as Guest
  ####################################
  test 'guest should not change actor' do
    put actors_path(na: argu.profile.id)
    assert_response 403
    assert_nil cookies['a_a']
  end

  ####################################
  # as User
  ####################################
  let(:user) { create(:user) }

  test 'user should not change actor' do
    sign_in user
    put actors_path(na: argu.profile.id)
    assert_response 403
    assert_nil cookies['a_a']
  end

  ####################################
  # as Super Admin
  ####################################
  let(:super_admin) { create_super_admin(argu) }

  test 'super admin should change actor' do
    sign_in super_admin
    put actors_path(na: argu.profile.id)
    assert_redirected_to root_path
    assert_equal cookies['a_a'].to_i, argu.profile.id
  end

  test 'unconfirmed super admin should not change actor' do
    sign_in super_admin
    super_admin.primary_email_record.update(confirmed_at: nil)
    put actors_path(na: argu.profile.id)
    assert_response 403
    assert_nil cookies['a_a']
  end
end

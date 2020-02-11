# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  let(:user) { create(:user) }
  define_freetown

  ####################################
  # As Guest
  ####################################
  test 'guest should redirect on home' do
    sign_in :guest_user

    get :home, format: :n3
    expect_ontola_action(redirect: freetown.iri)
  end

  ####################################
  # As User
  ####################################
  test 'user should redirect on home' do
    sign_in user
    get :home, format: :n3
    expect_ontola_action(redirect: freetown.iri)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should redirect on home' do
    sign_in staff
    get :home, format: :n3
    expect_ontola_action(redirect: "#{argu.iri}/feed")
  end
end

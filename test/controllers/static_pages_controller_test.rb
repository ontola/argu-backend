# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  EXCLUDED_METHODS = %i[about modern how_argu_works persist_cookie new_discussion not_found
                        dismiss_announcement context user_context developers home token].freeze

  let(:user) { create(:user) }
  define_freetown
  let(:question) { create(:question, parent: freetown) }
  let(:motion) { create(:motion, parent: question) }
  let(:blog_post) { create(:blog_post, parent: motion) }
  let(:vote) { create(:vote, parent: motion.default_vote_event) }
  let(:argument) { create(:argument, parent: motion) }
  let(:comment) { create(:comment, parent: argument) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get home' do
    get :home
    assert_response 200
    assert_select '.activity-feed', 0
    assert_select '.landing__wrapper', 1
  end

  test 'guest should get token' do
    get :token
    assert_response 200
  end

  test 'guest n3 should redirect on home' do
    get :home, format: :n3
    assert_redirected_to freetown.iri_path
  end

  ####################################
  # As User
  ####################################
  test 'user should get home' do
    get :home
    sign_in user
    assert_response 200
    assert_select '.activity-feed', 0
    assert_select '.landing__wrapper', 1
  end

  test 'user should get redirect' do
    sign_in user

    StaticPagesController.public_instance_methods(false).-(EXCLUDED_METHODS).each do |action|
      get action
      assert_response 302, "#{action} doesn't redirect"
    end

    get :developers
    assert_response 403, "developers doesn't 403"
  end

  test 'user should get how_argu_works' do
    sign_in user

    get :how_argu_works

    assert_response 200
  end

  test 'user n3 should redirect on home' do
    sign_in user
    get :home, format: :n3
    assert_redirected_to freetown.iri_path
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get activity feed' do
    trigger_activity_creation
    sign_in staff
    create(:favorite, edge: freetown, user: staff)

    get :home

    assert_response 200
    assert_select '.activity-feed', 1
    assert_select '.landing__wrapper', 0
  end

  test 'staff n3 should redirect on home' do
    sign_in staff
    get :home, format: :n3
    assert_redirected_to '/feed'
  end

  private

  def activities
    Activity.to_a
  end

  def trigger_activity_creation
    [blog_post, comment, vote]
  end
end

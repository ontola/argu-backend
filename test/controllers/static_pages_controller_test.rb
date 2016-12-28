# frozen_string_literal: true
require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  EXCLUDED_METHODS = [:modern, :how_argu_works, :persist_cookie, :new_discussion,
                      :dismiss_announcement, :context, :developers].freeze

  let(:user) { create(:user) }
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: question.edge) }
  let(:blog_post) { create(:blog_post, parent: motion.edge, happening_attributes: {happened_at: DateTime.current}) }
  let(:vote) { create(:vote, parent: motion.default_vote_event.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let(:comment) { create(:comment, parent: argument.edge) }

  ####################################
  # As User
  ####################################
  test 'should get redirect' do
    sign_in user

    StaticPagesController.public_instance_methods(false).-(EXCLUDED_METHODS).each do |action|
      get action
      assert_response 302, "#{action} doesn't redirect"
    end

    get :developers
    assert_response 403, "developers doesn't 403"
  end

  test 'should get how_argu_works' do
    sign_in user

    get :how_argu_works

    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get activity feed' do
    trigger_activity_creation
    sign_in staff
    create(:favorite, edge: freetown.edge, user: staff)

    get :home

    assert_response 200
    assert_equal activities, activities & assigns(:activities)
  end

  private

  def activities
    Activity.loggings.to_a
  end

  def trigger_activity_creation
    [blog_post, comment, vote]
  end
end

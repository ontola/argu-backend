# frozen_string_literal: true

require 'test_helper'

class FeedTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let!(:subject) { create(:motion, :with_votes, parent: freetown, creator: publisher.profile) }
  let!(:cairo_motion) { create(:motion, parent: cairo, creator: publisher.profile) }
  let!(:unpublished_motion) do
    create(:motion, parent: freetown, argu_publication_attributes: {draft: true})
  end
  let!(:publisher) { create(:user) }
  let!(:trashed_motion) do
    m = create(:motion, parent: freetown)
    ActsAsTenant.with_tenant(argu) do
      TrashService.new(m, options: {user_context: UserContext.new(user: publisher, profile: publisher.profile)}).commit
    end
    m
  end
  let!(:unpublished_motion_argument) { create(:pro_argument, parent: unpublished_motion) }
  let!(:trashed_motion_argument) { create(:pro_argument, parent: trashed_motion) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/feed nq' do
    sign_in create_guest_user

    visit_motion_feed(accept: :nq)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get page/feed nq' do
    sign_in user
    visit_argu_feed(accept: :nq)
  end

  test 'user should get page/feed nq after publish' do
    sign_in user
    Sidekiq::Testing.inline! do
      unpublished_motion.argu_publication.update!(published_at: Time.current)
    end
    visit_argu_feed(accept: :nq, count: 9)
  end

  test 'user should get page/feed nq after untrash' do
    sign_in user
    trashed_motion.untrash
    visit_argu_feed(accept: :nq, count: 9)
  end

  test 'user should get motion/feed nq' do
    sign_in user

    visit_motion_feed(accept: :nq)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get page/feed nq including cairo motion' do
    sign_in staff
    visit_argu_feed(accept: :nq, count: 8)
  end

  test 'staff should get motion/feed nq' do
    sign_in staff

    visit_motion_feed(accept: :nq)
  end

  private

  # Render activity of Motion#publish, 6 comments
  def assert_activity_count(accept: :nq, count: nil, parent: subject)
    case accept
    when :nq
      collection = ActsAsTenant.with_tenant(argu) do
        feed(parent).collection_iri(:activities, type: :paginated)
      end
      expect_triple(collection, NS.as[:totalItems], count)
    else
      raise 'Wrong format'
    end
  end

  def init_content
    Activity.update_all(created_at: 1.second.ago) # rubocop:disable Rails/SkipsModelValidations
  end

  def feed(parent)
    Feed.new(parent: parent)
  end

  def visit_argu_feed(accept: :nq, count: 7)
    init_content

    get feeds_iri(argu, type: :paginated),
        headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: count, parent: argu)
  end

  def visit_motion_feed(accept: :nq)
    init_content

    get feeds_iri(subject, type: :paginated), headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: 7)
  end
end

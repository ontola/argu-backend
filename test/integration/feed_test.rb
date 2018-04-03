# frozen_string_literal: true

require 'test_helper'

class FeedTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { create(:motion, :with_votes, parent: freetown.edge, creator: publisher.profile) }
  let(:unpublished_motion) do
    create(:motion, parent: freetown.edge, edge_attributes: {argu_publication_attributes: {draft: true}})
  end
  let(:publisher) { create(:user) }
  let(:trashed_motion) do
    m = create(:motion, parent: freetown.edge)
    TrashService.new(m, options: {creator: publisher.profile, publisher: publisher}).commit
    m
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/feed nt' do
    get motion_feed_path(subject),
        params: {format: :nt}

    assert_response 200

    assert_activity_count(format: :nt)
  end

  test 'guest should get motion/feed html' do
    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get forum/feed html' do
    sign_in user
    unpublished_motion
    trashed_motion

    get forum_feed_path(freetown)

    assert_response 200

    assert_select '.activity-feed'

    # Only render activity of Motion#publish
    assert_select '.activity-feed .activity', 1
  end

  test 'user should get motion/feed nt' do
    sign_in user

    get motion_feed_path(subject),
        params: {format: :nt}

    assert_response 200

    assert_activity_count(format: :nt)
  end

  test 'user should get motion/feed html' do
    sign_in user

    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count
  end

  test 'user should get complete motion/feed nt' do
    sign_in user

    get motion_feed_path(subject),
        params: {format: :nt, complete: true}

    assert_response 200

    assert_activity_count(format: :nt, staff: true, complete: true)
  end

  test 'user should get complete motion/feed html' do
    sign_in user

    get motion_feed_path(subject),
        params: {complete: true}

    assert_response 200

    assert_activity_count(staff: true, complete: true)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get motion/feed nt' do
    sign_in staff

    get motion_feed_path(subject),
        params: {format: :nt}

    assert_response 200

    assert_activity_count(format: :nt, staff: true)
  end

  test 'staff should get motion/feed html' do
    sign_in staff

    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count(staff: true)
  end

  test 'staff should get complete motion/feed nt' do
    sign_in staff

    get motion_feed_path(subject),
        params: {format: :nt, complete: true}

    assert_response 200

    assert_activity_count(format: :nt, staff: true, complete: true)
  end

  test 'staff should get complete motion/feed html' do
    sign_in staff

    get motion_feed_path(subject), params: {complete: true}

    assert_response 200

    assert_activity_count(staff: true, complete: true)
  end

  test 'staff should get additional activities for motion/feed js' do
    sign_in staff

    get motion_feed_path(subject), params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  test 'staff should get additional activities for user/feed js' do
    sign_in staff
    subject

    get user_feed_path(publisher), params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  test 'staff should get additional activities for favorites/feed js' do
    sign_in staff
    create(:favorite, edge: freetown.edge, user: staff)
    subject

    get feed_path, params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  private

  # Render activity of Motion#create, Motion#publish, 6 comments, 6 public votes and 3 private votes
  def assert_activity_count(format: :html, staff: false, complete: false)
    count = staff && complete ? 10 : 7
    case format
    when :html
      assert_select '.activity-feed .activity', count
    when :nt
      expect_triple(RDF::URI("#{feed(subject).iri}/feed?page=1&type=paginated"), NS::ARGU[:totalCount], count)
    else
      raise 'Wrong format'
    end
  end

  def feed(parent)
    Feed.new(parent: parent)
  end
end

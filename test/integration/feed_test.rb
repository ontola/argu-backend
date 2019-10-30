# frozen_string_literal: true

require 'test_helper'

class FeedTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { create(:motion, :with_votes, parent: freetown, creator: publisher.profile) }
  let(:unpublished_motion) do
    create(:motion, parent: freetown, argu_publication_attributes: {draft: true})
  end
  let(:publisher) { create(:user) }
  let(:trashed_motion) do
    m = create(:motion, parent: freetown)
    ActsAsTenant.with_tenant(argu) do
      TrashService.new(m, options: {creator: publisher.profile, publisher: publisher}).commit
    end
    m
  end
  let(:unpublished_motion_argument) { create(:argument, parent: unpublished_motion) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/feed nq' do
    sign_in create_guest_user, Doorkeeper::Application.argu_front_end

    visit_motion_feed(accept: :nq)
  end

  test 'guest should get motion/feed html' do
    visit_motion_feed
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get forum/feed html' do
    sign_in user
    visit_freetown_feed
  end

  test 'user should get forum/feed nq' do
    sign_in user, Doorkeeper::Application.argu_front_end
    visit_freetown_feed(accept: :nq)
  end

  test 'user should get motion/feed nq' do
    sign_in user, Doorkeeper::Application.argu_front_end

    visit_motion_feed(accept: :nq)
  end

  test 'user should get motion/feed html' do
    sign_in user

    visit_motion_feed
  end

  test 'user should get complete motion/feed nq' do
    sign_in user, Doorkeeper::Application.argu_front_end

    visit_motion_feed(accept: :nq, complete: true)
  end

  test 'user should get complete motion/feed html' do
    sign_in user

    visit_motion_feed(complete: true)
  end

  test 'user should get additional activities for user/feed js' do
    sign_in user
    subject

    get feeds_iri(publisher), params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get forum/feed html' do
    sign_in staff
    visit_freetown_feed(count: 9)
  end

  test 'staff should get forum/feed nq' do
    sign_in staff, Doorkeeper::Application.argu_front_end
    visit_freetown_feed(accept: :nq, count: 9)
  end

  test 'staff should get motion/feed nq' do
    sign_in staff, Doorkeeper::Application.argu_front_end

    visit_motion_feed(accept: :nq)
  end

  test 'staff should get motion/feed html' do
    sign_in staff

    visit_motion_feed
  end

  test 'staff should get complete motion/feed nq' do
    sign_in staff, Doorkeeper::Application.argu_front_end

    visit_motion_feed(accept: :nq, complete: true)
  end

  test 'staff should get complete motion/feed html' do
    sign_in staff

    visit_motion_feed(complete: true)
  end

  test 'staff should get additional activities for motion/feed js' do
    sign_in staff

    get feeds_iri(subject),
        params: {from_time: 1.hour.from_now, complete: false},
        headers: argu_headers(accept: :js)

    assert_response 200
  end

  test 'staff should get additional activities for user/feed js' do
    sign_in staff
    subject

    get feeds_iri(publisher),
        params: {from_time: 1.hour.from_now, complete: false},
        headers: argu_headers(accept: :js)

    assert_response 200
  end

  test 'staff should get additional activities for favorites/feed js' do
    sign_in staff
    create(:favorite, edge: freetown, user: staff)
    subject

    get feed_path,
        params: {from_time: 1.hour.from_now, complete: false},
        headers: argu_headers(accept: :js)

    assert_response 200
  end

  private

  # Render activity of Motion#create, Motion#publish, 6 comments, 6 public votes and 3 private votes
  def assert_activity_count(accept: :html, complete: false, count: nil, parent: subject)
    case accept
    when :html
      assert_select '.activity-feed .activity', count
    when :nq
      collection = RDF::URI("#{resource_iri(feed(parent))}/feed#{complete ? '?complete=true' : ''}")
      puts "looking for #{collection}"
      view = rdf_body.query([collection, NS::ONTOLA[:pages]]).first.object
      expect_triple(view, NS::AS[:totalItems], count)
    else
      raise 'Wrong format'
    end
  end

  def init_content(_resources = subject)
    Activity.update_all(created_at: 1.second.ago) # rubocop:disable Rails/SkipsModelValidations
  end

  def feed(parent)
    Feed.new(parent: parent, root_id: parent.try(:root_id))
  end

  def visit_freetown_feed(accept: :html, count: 8)
    init_content([subject, unpublished_motion, unpublished_motion_argument, trashed_motion])

    get feeds_iri(freetown),
        headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: count, parent: freetown)
  end

  def visit_motion_feed(accept: :html, complete: false)
    init_content

    count = complete ? 10 : 7

    get feeds_iri(subject),
        params: complete ? {complete: true} : {},
        headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: count, complete: complete)
  end
end

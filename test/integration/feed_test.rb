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
      TrashService.new(m, options: {user_context: UserContext.new(user: publisher, profile: publisher.profile)}).commit
    end
    m
  end
  let(:unpublished_motion_argument) { create(:pro_argument, parent: unpublished_motion) }

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

  test 'user should get forum/feed nq' do
    sign_in user
    visit_freetown_feed(accept: :nq)
  end

  test 'user should get motion/feed nq' do
    sign_in user

    visit_motion_feed(accept: :nq)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get forum/feed nq' do
    sign_in staff
    visit_freetown_feed(accept: :nq, count: 9)
  end

  test 'staff should get motion/feed nq' do
    sign_in staff

    visit_motion_feed(accept: :nq)
  end

  private

  # Render activity of Motion#create, Motion#publish, 6 comments, 6 public votes and 3 private votes
  def assert_activity_count(accept: :nq, complete: false, count: nil, parent: subject) # rubocop:disable Metrics/AbcSize
    case accept
    when :nq
      collection = ActsAsTenant.with_tenant(argu) do
        feed(parent, complete).activity_collection.iri
        # RDF::URI("#{resource_iri(feed(parent))}/feed#{complete ? '?complete=true' : ''}")
      end
      view = rdf_body.query([collection, NS.ontola[:pages]]).first.object
      expect_triple(view, NS.as[:totalItems], count)
    else
      raise 'Wrong format'
    end
  end

  def init_content(_resources = subject)
    Activity.update_all(created_at: 1.second.ago) # rubocop:disable Rails/SkipsModelValidations
  end

  def feed(parent, complete)
    Feed.new(parent: parent, relevant_only: !complete)
  end

  def visit_freetown_feed(accept: :nq, count: 8)
    init_content([subject, unpublished_motion, unpublished_motion_argument, trashed_motion])

    get feeds_iri(freetown),
        headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: count, parent: freetown)
  end

  def visit_motion_feed(accept: :nq, complete: false)
    init_content

    count = complete ? 10 : 7

    get feeds_iri(subject),
        params: complete ? {complete: true} : {},
        headers: argu_headers(accept: accept)

    assert_response 200

    assert_activity_count(accept: accept, count: count, complete: complete)
  end
end

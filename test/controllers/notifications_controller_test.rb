# frozen_string_literal: true

require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:unconfirmed_vote) do
    create(:vote, parent: motion.default_vote_event, creator: unconfirmed.profile, publisher: unconfirmed)
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should not get index' do
    followed_content(unconfirmed)
    sign_in :guest_user

    get :index, format: :nq, params: {type: :paginated}

    assert_response 200

    expect_triple(Notification.collection_iri(type: :paginated), NS.as[:totalItems], 0)
  end

  ####################################
  # As unconfirmed user
  ####################################
  let(:unconfirmed) { create(:unconfirmed_user) }

  test 'unconfirmed user with notifications should get index' do
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq, params: {type: :paginated}

    assert_response 200

    expect_triple(Notification.collection_iri(type: :paginated), NS.as[:totalItems], 4)
  end

  test 'unconfirmed user with notifications and redis_vote should get index' do
    unconfirmed_vote
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq, params: {type: :paginated}

    assert_response 200
    expect_triple(Notification.collection_iri(type: :paginated), NS.as[:totalItems], 5)
  end

  test 'unconfirmed user with notifications and redis_vote should get index with before' do
    unconfirmed_vote
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq, params: {'before[]' => {NS.schema.dateCreated => 1.day.from_now.utc.iso8601(6)}.to_param}

    assert_response 200
    expect_triple(*member_triple(0))
    expect_triple(*member_triple(1))
    expect_triple(*member_triple(2))
    expect_triple(*member_triple(3))
    expect_triple(*member_triple(4))
    refute_triple(*member_triple(5))
  end

  test 'unconfirmed user with notifications and redis_vote should not get newer notifications' do
    unconfirmed_vote
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq, params: {'before[]' => {NS.schema.dateCreated => 1.day.ago.utc.iso8601(6)}.to_param}

    assert_response 200
    refute_triple(*member_triple(0))
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }
  let(:user_with_notifications) { create(:user) }

  test 'user without notifications should get index no content' do
    sign_in user

    get :index, format: :nq, params: {type: :paginated}

    assert_response 200
    expect_triple(Notification.collection_iri(type: :paginated), NS.as[:totalItems], 0)
  end

  test 'user with notifications should get index nq' do
    sign_in user
    followed_content(user)

    sleep(1.second)

    get :index, format: :nq, params: {type: :paginated}

    assert_response 200
    expect_triple(Notification.collection_iri(type: :paginated), NS.as[:totalItems], 4)
  end

  private

  def followed_content(user) # rubocop:disable Metrics/MethodLength
    user.follows.destroy_all
    parent = freetown
    create(:follow, followable: parent, follower: user)
    %i[question motion pro_argument comment].each do |type|
      trackable = create(type, parent: parent)
      if %i[question motion pro_argument].include?(type)
        parent = trackable
        create(:follow, followable: parent, follower: user)
      end
    end
    create(:vote, parent: parent.default_vote_event)
  end

  def member_triple(index)
    view = expect_triple(nil, RDF.type, NS.ontola[:InfiniteView]).subjects.first
    [RDF::URI("#{view}#members"), RDF["_#{index}"], nil]
  end
end

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

    get :index, format: :nq

    assert_response 200

    view = expect_triple(Notification.root_collection.iri, NS::ONTOLA[:pages], nil).objects.first
    expect_triple(view, NS::AS[:totalItems], 0)
  end

  ####################################
  # As unconfirmed user
  ####################################
  let(:unconfirmed) { create(:unconfirmed_user) }

  test 'unconfirmed user with notifications should get index' do
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq

    assert_response 200, format: :nq
    view = expect_triple(Notification.root_collection.iri, NS::ONTOLA[:pages], nil).objects.first
    expect_triple(view, NS::AS[:totalItems], 4)
  end

  test 'unconfirmed user with notifications and redis_vote should get index' do
    unconfirmed_vote
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :nq

    assert_response 200
    view = expect_triple(Notification.root_collection.iri, NS::ONTOLA[:pages], nil).objects.first
    expect_triple(view, NS::AS[:totalItems], 5)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }
  let(:user_with_notifications) { create(:user) }

  test 'user without notifications should get index no content' do
    sign_in user

    get :index, format: :nq

    assert_response 200
    view = expect_triple(Notification.root_collection.iri, NS::ONTOLA[:pages], nil).objects.first
    expect_triple(view, NS::AS[:totalItems], 0)
  end

  test 'user with notifications should get index nq' do
    sign_in user
    followed_content(user)

    sleep(1.second)

    get :index, format: :nq

    assert_response 200
    view = expect_triple(Notification.root_collection.iri, NS::ONTOLA[:pages], nil).objects.first
    expect_triple(view, NS::AS[:totalItems], 4)
    user.notifications.each { |n| expect_triple(n.iri, NS::ONTOLA[:readAction], nil) }
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
end

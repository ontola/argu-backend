# frozen_string_literal: true

require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:unconfirmed_vote) do
    create(:vote, parent: motion.default_vote_event.edge, creator: unconfirmed.profile, publisher: unconfirmed)
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should not get index' do
    get :index

    assert_response 204
  end

  ####################################
  # As unconfirmed user
  ####################################
  let(:unconfirmed) { create(:user, :unconfirmed) }

  test 'unconfirmed user with notifications should get index' do
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :json

    assert_response 200
    assert_equal 4, parsed_body['notifications']['notifications'].count
  end

  test 'unconfirmed user with notifications and redis_vote should get index' do
    unconfirmed_vote
    sign_in unconfirmed
    followed_content(unconfirmed)

    get :index, format: :json

    assert_response 200
    assert_equal 5, parsed_body['notifications']['notifications'].count
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }
  let(:user_with_notifications) { create(:user) }

  test 'user without notifications should get index no content' do
    sign_in user

    get :index, format: :json

    assert_response 204
  end

  test 'user with notifications should get index' do
    sign_in user
    followed_content(user)

    get :index, format: :json

    assert_response 200
    assert_equal 4, parsed_body['notifications']['notifications'].count
  end

  private

  def followed_content(user)
    parent = freetown
    create(:follow, followable: parent.edge, follower: user)
    %i(question motion argument comment).each do |type|
      trackable = create(type, parent: parent.edge)
      if %i(question motion argument).include?(type)
        parent = trackable
        create(:follow, followable: parent.edge, follower: user)
      end
    end
    create(:vote, parent: parent.default_vote_event.edge)
  end
end

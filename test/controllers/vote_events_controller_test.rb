# frozen_string_literal: true

require 'test_helper'

class VoteEventsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:vote_event) { create(:vote_event, parent: motion) }
  let(:argument) { create(:pro_argument, :with_comments, parent: motion) }
  let!(:public_vote) { create(:vote, parent: vote_event) }
  let!(:hidden_vote) do
    create(:vote, parent: vote_event, creator: user_hidden_votes.profile, publisher: user_hidden_votes)
  end
  let(:user_hidden_votes) { create(:user, show_feed: false) }

  ####################################
  # VoteEvents of Motion
  ####################################
  test 'should get show vote_event of motion' do
    get :show, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment, id: vote_event.fragment}
    assert_response 200

    expect_relationship('parent')
    expect_relationship('creator')

    expect_relationship('vote_collection', size: 1)
    expect_included(collection_iri(vote_event, :votes))
    expect_included(vote_event.votes.joins(:publisher).where(users: {show_feed: true}).map(&:iri))
    expect_not_included(vote_event.votes.joins(:publisher).where(users: {show_feed: false}).map(&:iri))
  end

  test 'should get index vote_events of motion' do
    get :index, params: {format: :json_api, root_id: argu.url, motion_id: motion.fragment}
    assert_response 200

    expect_relationship('part_of')
    expect_view_members(expect_default_view, 2)

    expect_not_included(
      vote_event.votes.joins(:publisher).where(users: {show_feed: false}).map(&:iri)
    )
  end
end

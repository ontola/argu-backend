# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:argument) { motion.pro_arguments.untrashed.first }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.default_vote_event.votes.first }
  let(:linked_record) { LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:user) { create(:user) }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, root_id: argu.url, id: vote.fragment}
    assert_response 200

    expect_relationship('partOf')
    expect_relationship('creator')
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index,
        params: {
          format: :json_api,
          root_id: argu.url,
          motion_id: motion.fragment,
          vote_event_id: vote_event.fragment
        }
    assert_response 200

    expect_relationship('partOf')

    expect_relationship('defaultFilteredCollections', size: 3)

    included_votes = vote_event.votes.joins(:publisher).where(users: {show_feed: true})
    expect_view_members(expect_default_view, included_votes.count)
    expect_not_included(vote_event.votes.joins(:publisher).where(users: {show_feed: false}).map(&:iri))
  end

  test 'should get index votes of vote_event with filter' do
    get :index,
        params: {
          format: :json_api,
          root_id: argu.url,
          motion_id: motion.fragment,
          vote_event_id: vote_event.fragment,
          'filter[]' => 'option=yes'
        }
    assert_response 200

    expect_relationship('unfilteredCollection')

    included_votes = vote_event.votes.joins(:publisher).where(for: :pro, users: {show_feed: true})
    expect_view_members(expect_default_view, included_votes.count)
    expect_not_included(vote_event.votes.where(for: :con))
  end
end

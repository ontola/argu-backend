# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:argument) { motion.pro_arguments.untrashed.first }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.default_vote_event.votes.first }
  let(:user) { create(:user) }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, root_id: argu.url, id: vote.fragment}
    assert_response 200

    expect_relationship('parent')
    expect_relationship('creator')
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index,
        params: {
          format: :json_api,
          parent_iri: parent_iri_for(vote_event)
        }
    assert_response 200

    expect_relationship('part_of')

    included_votes = vote_event.votes.joins(:publisher).where(users: {show_feed: true})
    expect_view_members(expect_default_view, included_votes.count)
    expect_not_included(vote_event.votes.joins(:publisher).where(users: {show_feed: false}).map(&:iri))
  end

  test 'should get index votes of vote_event with filter' do
    option_term = vote_event.option_record!(NS.argu[:yes])
    get :index,
        params: {
          format: :json_api,
          parent_iri: parent_iri_for(vote_event),
          'filter[]' => "http://schema.org/option=#{option_term.iri}"
        }
    assert_response 200

    expect_relationship('unfiltered_collection')

    included_votes = vote_event.votes.joins(:publisher).where(
      option: option_term,
      users: {show_feed: true}
    )
    expect_view_members(expect_default_view, included_votes.count)
    expect_not_included(vote_event.votes.where(option: vote_event.option_record!(NS.argu[:no])))
  end
end

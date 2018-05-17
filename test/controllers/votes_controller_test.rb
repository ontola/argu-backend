# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:argument) { motion.pro_arguments.untrashed.first }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.default_vote_event.votes.first }
  let(:linked_record) { LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:user) { create(:user) }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, root_id: argu.url, id: vote.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)
  end

  ####################################
  # Create
  ####################################
  test 'should post create vote for argument as JS' do
    sign_in user
    post :create, params: {format: :js, root_id: argu.url, pro_argument_id: argument.edge.fragment, for: 'pro'}
    assert_response 200
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index,
        params: {
          format: :json_api,
          root_id: argu.url,
          motion_id: motion.edge.fragment,
          vote_event_id: vote_event.edge.fragment
        }
    assert_response 200

    expect_relationship('partOf', 1)

    view_sequence = expect_relationship('viewSequence')
    assert_equal expect_included(view_sequence['data']['id'])['relationships']['members']['data'].count, 3
    %w[yes other no].each do |side|
      expect_included(collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, type: 'paginated'))
      expect_included(
        collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated')
      )
    end
    expect_included(vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map(&:iri))
    expect_not_included(vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map(&:iri))
  end
end

# frozen_string_literal: true

require 'test_helper'

class VoteMatchesControllerTest < ActionController::TestCase
  let(:user) { create(:user) }
  let!(:user_vote_match) { create(:vote_match, creator: user.profile) }
  let(:page) { create(:page) }
  let!(:page_vote_match) { create(:vote_match, creator: page.profile) }

  ####################################
  # Show
  ####################################
  test 'should get show vote_match' do
    get :show, params: {format: :json_api, id: user_vote_match.id}
    assert_response 200

    expect_relationship('creator')

    expect_relationship('voteables', size: 2)
    expect_no_relationship('voteComparables')
  end

  ####################################
  # Index
  ####################################
  test 'should get index vote_matches' do
    get :index, params: {format: :json_api}
    assert_response 200

    expect_no_relationship('partOf')

    expect_default_view
    expect_included(argu_url('/vote_matches', page: 1))
    expect_included(VoteMatch.all.map(&:iri))
  end

  test 'should get index vote_matches page 1' do
    get :index, params: {format: :json_api, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, VoteMatch.count)
    expect_included(VoteMatch.all.map(&:iri))
  end

  test 'should get index vote_matches for page' do
    get :index, params: {page_id: page.url, format: :json_api}
    assert_response 200

    expect_relationship('partOf')

    expect_default_view
    expect_included(argu_url("/#{page.url}/vote_matches", page: 1))
    expect_included(VoteMatch.where(creator: page.profile).map(&:iri))
    expect_not_included(VoteMatch.where('creator_id != ?', page.profile.id).map(&:iri))
  end
end

# frozen_string_literal: true
require 'test_helper'

class VoteMatchesControllerTest < ActionController::TestCase
  let!(:vote_match) { create(:vote_match) }

  ####################################
  # Show
  ####################################
  test 'should get show vote_match' do
    get :show, params: {format: :json_api, id: vote_match.id}
    assert_response 200

    assert_relationship('creator', 1)

    assert_relationship('voteables', 1)
    assert_relationship('voteComparables', 1)
  end

  ####################################
  # Index
  ####################################
  test 'should get index vote_matches' do
    get :index, params: {format: :json_api}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included('/vote_matches?page=1')
    assert_included(VoteMatch.all.map { |r| "/vote_matches/#{r.id}" })
  end

  test 'should get index vote_matches page 1' do
    get :index, params: {format: :json_api, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', VoteMatch.count)
    assert_included(VoteMatch.all.map { |r| "/vote_matches/#{r.id}" })
  end
end

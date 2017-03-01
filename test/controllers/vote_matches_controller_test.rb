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

    assert_relationship('creator', 1)

    assert_relationship('voteables', 2)
    assert_relationship('voteComparables', 0)
  end

  ####################################
  # Index
  ####################################
  test 'should get index vote_matches' do
    get :index, params: {format: :json_api}
    assert_response 200

    assert_relationship('parent', 0)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included('/vote_matches?page=1')
    assert_included(VoteMatch.all.map { |r| "/vote_matches/#{r.id}" })
  end

  test 'should get index vote_matches page 1' do
    get :index, params: {format: :json_api, page: 1}
    assert_response 200

    assert_relationship('parent', 0)
    assert_relationship('views', 0)

    assert_relationship('members', VoteMatch.count)
    assert_included(VoteMatch.all.map { |r| "/vote_matches/#{r.id}" })
  end

  test 'should get index vote_matches for user' do
    get :index, params: {user_id: user.id, format: :json_api}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/u/#{user.id}/vote_matches?page=1")
    assert_included(VoteMatch.where(creator: user.profile).map { |r| "/vote_matches/#{r.id}" })
    assert_not_included(VoteMatch.where('creator_id != ?', user.profile.id).map { |r| "/vote_matches/#{r.id}" })
  end

  test 'should get index vote_matches for page' do
    get :index, params: {page_id: page.id, format: :json_api}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/o/#{page.id}/vote_matches?page=1")
    assert_included(VoteMatch.where(creator: page.profile).map { |r| "/vote_matches/#{r.id}" })
    assert_not_included(VoteMatch.where('creator_id != ?', page.profile.id).map { |r| "/vote_matches/#{r.id}" })
  end
end

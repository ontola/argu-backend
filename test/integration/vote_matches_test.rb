# frozen_string_literal: true

require 'test_helper'

class VoteMatchesTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:subject) { create(:vote_match, publisher: creator) }
  let(:user_vote_match) { create(:vote_match, publisher: creator, shortname: 'user_vote_match') }
  let(:page_vote_match) do
    create(:vote_match, publisher: creator, creator: create(:page).profile, shortname: 'page_vote_match')
  end

  def record_path(record)
    case record
    when 'page_vote_match'
      page_vote_match_url(page_id: page_vote_match.creator.profileable.url, id: 'page_vote_match')
    when 'user_vote_match'
      user_vote_match_url(user_id: user_vote_match.creator.profileable.url, id: 'user_vote_match')
    else
      url_for([model_sym, id: record])
    end
  end

  def self.has_voteables
    "assert_equal resource.reload.voteables.pluck(:iri), ['https://example.com/1', 'https://example.com/2']"
  end

  def self.has_other_voteables
    "assert_equal resource.reload.voteables.pluck(:iri), ['https://example.com/a', 'https://example.com/b']"
  end

  define_tests do
    hash = {}
    define_test(hash, :show) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        super_admin: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
    define_test(hash, :show, suffix: ' of user', options: {record: 'user_vote_match'}) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        super_admin: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
    define_test(hash, :show, suffix: ' of page', options: {record: 'page_vote_match'}) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        super_admin: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
    define_test(hash, :create, options: {differences: [['VoteMatch', 1], ['ListItem', 2]]}) do
      {
        guest: exp_res(should: false, response: 401),
        user: exp_res(should: true, response: 201, asserts: [has_voteables]),
        staff: exp_res(should: true, response: 201, asserts: [has_voteables])
      }
    end
    options = {
      attributes: {
        voteables: [
          {resource_type: 'argu:Motion', iri: 'https://example.com/a'},
          {resource_type: 'argu:Motion', iri: 'https://example.com/b'}
        ]
      },
      differences: [['VoteMatch', 1]]
    }
    define_test(hash, :create, suffix: ' with voteables', options: options) do
      {user: exp_res(should: true, response: 201, asserts: [has_other_voteables])}
    end
    define_test(hash, :update, options: {differences: []}) do
      {
        guest: exp_res(should: false, response: 401),
        user: exp_res(should: false, response: 403),
        creator: exp_res(should: true, response: 204),
        staff: exp_res(should: true, response: 204)
      }
    end
    options = {
      attributes: {
        voteables: [
          {resource_type: 'argu:Motion', iri: 'https://example.com/a'},
          {resource_type: 'argu:Motion', iri: 'https://example.com/b'}
        ]
      },
      differences: []
    }
    define_test(hash, :update, suffix: ' with voteables', options: options) do
      {creator: exp_res(should: true, response: 204, asserts: [has_other_voteables])}
    end
    define_test(hash, :destroy, options: {differences: [['VoteMatch', -1], ['ListItem', -2]]}) do
      {
        guest: exp_res(should: false, response: 401),
        user: exp_res(should: false, response: 403),
        creator: exp_res(should: true, response: 204),
        staff: exp_res(should: true, response: 204)
      }
    end
  end

  private

  def request_format
    :json_api
  end
end

# frozen_string_literal: true
require 'test_helper'

class VoteMatchesControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let!(:subject) { create(:vote_match, publisher: creator, parent: freetown.edge) }
  let(:user_vote_match) do
    create(:vote_match, publisher: creator, parent: freetown.edge, shortname: 'user_vote_match')
  end
  let(:page_vote_match) do
    create(:vote_match,
           publisher: creator,
           creator: create(:page).profile,
           parent: freetown.edge,
           shortname: 'page_vote_match')
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

  define_tests do
    hash = {}
    define_test(hash, :show) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        moderator: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        owner: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
    define_test(hash, :show, suffix: ' of user', options: {record: 'user_vote_match'}) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        moderator: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        owner: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
    define_test(hash, :show, suffix: ' of page', options: {record: 'page_vote_match'}) do
      {
        guest: exp_res(should: true, response: 200),
        user: exp_res(should: true, response: 200),
        member: exp_res(should: true, response: 200),
        non_member: exp_res(should: true, response: 200),
        moderator: exp_res(should: true, response: 200),
        manager: exp_res(should: true, response: 200),
        owner: exp_res(should: true, response: 200),
        staff: exp_res(should: true, response: 200)
      }
    end
  end

  private

  def request_format
    :json_api
  end
end

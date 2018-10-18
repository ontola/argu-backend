# frozen_string_literal: true

require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, parent: freetown) }
  let(:question_motion) { create(:motion, :with_votes, parent: question) }
  let(:motion) { create(:motion, :with_arguments, :with_votes, :with_attachments, parent: freetown) }
  let(:vote_event) { motion.default_vote_event }

  ####################################
  # Show
  ####################################
  test 'should get show motion' do
    get :show, params: {format: :json_api, root_id: argu.url, id: motion.fragment}
    assert_response 200

    expect_relationship('partOf')
    expect_relationship('creator')

    expect_relationship('proArgumentCollection')
    expect_relationship('conArgumentCollection')
    expect_included(collection_iri(motion, :pro_arguments))
    expect_included(collection_iri(motion, :con_arguments))

    expect_relationship('attachmentCollection')
    expect_included(collection_iri(motion, :attachments))
    expect_included(motion.attachments.map(&:iri))

    expect_relationship('voteEventCollection')
    expect_included(vote_event.iri)
    expect_included(collection_iri(vote_event, :votes))
    %w[yes other no].each do |side|
      expect_included(collection_iri(vote_event, :votes, 'filter%5B%5D' => "option=#{side}"))
    end
    expect_not_included(motion.default_vote_event.votes.map(&:iri))
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    get :index, params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url}
    assert_response 200

    expect_relationship('partOf')

    expect_default_view
    expect_included(collection_iri(holland, :motions, page: 1, type: 'paginated'))
    expect_included(holland.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  test 'should get index motions of forum page 1' do
    get :index,
        params: {format: :json_api, root_id: holland.parent.url, forum_id: holland.url, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, holland.motions.untrashed.count)
    expect_included(holland.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, root_id: argu.url, question_id: question.fragment}
    assert_response 200

    expect_relationship('partOf')

    members = expect_view_members(expect_default_view, question.motions.active.count)
    vote_event = expect_included(expect_relationship('defaultVoteEvent', parent: members.first)['data']['id'])

    vote_event_votes = expect_included(expect_relationship('voteCollection', parent: vote_event)['data']['id'])

    filtered_collections = expect_relationship('defaultFilteredCollections', parent: vote_event_votes, size: 3)
    expect_included(filtered_collections['data'].map { |d| d['id'] })

    expect_included(collection_iri(question, :motions, type: 'paginated', page: 1))
    expect_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))
    expect_included(question.motions.untrashed.map { |m| m.default_vote_event.iri })
  end

  test 'should get index motions of question page 1' do
    get :index,
        params: {format: :json_api, root_id: argu.url, question_id: question.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, question.motions.untrashed.count)
    expect_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))

    expect_included(question.motions.untrashed.map { |m| m.default_vote_event.iri })
    expect_not_included(question.motions.trashed.map { |m| m.default_vote_event.votes }.map(&:iri))
  end

  test 'should include current_vote in get index motions of question page 1' do
    user_vote = question_motion.default_vote_event.votes.first
    user = user_vote.publisher

    sign_in user

    get :index,
        params: {format: :json_api, root_id: argu.url, question_id: question.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_included(user_vote.iri)
  end
end

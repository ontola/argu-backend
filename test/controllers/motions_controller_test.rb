# frozen_string_literal: true
require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, parent: freetown.edge) }
  let(:motion) { create(:motion, :with_arguments, :with_votes, :with_attachments, parent: freetown.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show motion' do
    get :show, params: {format: :json_api, id: motion.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('argumentCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/arguments"))
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'yes'}))
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'yes'}, page: 1))
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'no'}))
    expect_included(argu_url("/m/#{motion.id}/arguments", filter: {option: 'no'}, page: 1))
    expect_included(motion.arguments.untrashed.map { |a| argu_url("/a/#{a.id}") })
    expect_not_included(motion.arguments.trashed.map { |a| argu_url("/a/#{a.id}") })

    expect_relationship('attachmentCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/media_objects", filter: {used_as: 'attachment'}))
    expect_included(motion.attachments.map { |r| argu_url("/media_objects/#{r.id}") })

    expect_relationship('voteEventCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/vote_events"))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}"))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes"))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'yes'}))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'yes'}, page: 1))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'other'}))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'other'}, page: 1))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'no'}))
    expect_included(argu_url("/vote_events/#{motion.default_vote_event.id}/votes", filter: {option: 'no'}, page: 1))
    expect_included(
      motion.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      motion.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    get :index, params: {format: :json_api, forum_id: holland.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/f/#{holland.id}/motions", page: 1))
    expect_included(holland.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  test 'should get index motions of forum page 1' do
    get :index, params: {format: :json_api, forum_id: holland.id, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', holland.motions.untrashed.count)
    expect_included(holland.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, question_id: question.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url("/q/#{question.id}/motions", page: 1))
    expect_included(question.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  test 'should get index motions of question page 1' do
    get :index, params: {format: :json_api, question_id: question.id, page: 1}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)

    expect_relationship('members', question.motions.untrashed.count)
    expect_included(question.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end
end

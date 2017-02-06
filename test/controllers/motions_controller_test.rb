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

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)

    assert_relationship('argumentCollection', 1)
    assert_included("/m/#{motion.id}/arguments")
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=yes")
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=yes&page=1")
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=no")
    assert_included("/m/#{motion.id}/arguments?filter%5Boption%5D=no&page=1")
    assert_included(motion.arguments.untrashed.map { |a| "/a/#{a.id}" })
    assert_not_included(motion.arguments.trashed.map { |a| "/a/#{a.id}" })

    assert_relationship('attachmentCollection', 1)
    assert_included("/m/#{motion.id}/media_objects?filter%5Bused_as%5D=attachment")
    assert_included(motion.attachments.map { |r| "/media_objects/#{r.id}" })

    assert_relationship('voteEventCollection', 1)
    assert_included("/m/#{motion.id}/vote_events")
    assert_included("/vote_events/#{motion.default_vote_event.id}")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=yes")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=yes&page=1")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=other")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=other&page=1")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=no")
    assert_included("/vote_events/#{motion.default_vote_event.id}/votes?filter%5Boption%5D=no&page=1")
    assert_included(motion.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| "/v/#{v.id}" })
    assert_not_included(
      motion.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| "/v/#{v.id}" }
    )
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    get :index, params: {format: :json_api, forum_id: holland.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/f/#{holland.id}/motions?page=1")
    assert_included(holland.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(holland.motions.trashed.map { |m| "/m/#{m.id}" })
  end

  test 'should get index motions of forum page 1' do
    get :index, params: {format: :json_api, forum_id: holland.id, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', holland.motions.untrashed.count)
    assert_included(holland.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(holland.motions.trashed.map { |m| "/m/#{m.id}" })
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, question_id: question.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/q/#{question.id}/motions?page=1")
    assert_included(question.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(question.motions.trashed.map { |m| "/m/#{m.id}" })
  end

  test 'should get index motions of question page 1' do
    get :index, params: {format: :json_api, question_id: question.id, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', question.motions.untrashed.count)
    assert_included(question.motions.untrashed.map { |m| "/m/#{m.id}" })
    assert_not_included(question.motions.trashed.map { |m| "/m/#{m.id}" })
  end
end

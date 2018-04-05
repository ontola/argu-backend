# frozen_string_literal: true

require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, parent: freetown.edge) }
  let(:motion) { create(:motion, :with_arguments, :with_votes, :with_attachments, parent: freetown.edge) }
  let(:motion_votes_base_path) { "/m/#{motion.id}/vote_events/#{motion.default_vote_event.id}/votes" }

  ####################################
  # Show
  ####################################
  test 'should get show motion' do
    get :show, params: {format: :json_api, id: motion.id}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('proArgumentCollection', 1)
    expect_relationship('conArgumentCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/pros", type: 'paginated'))
    expect_included(argu_url("/m/#{motion.id}/pros", page: 1, type: 'paginated'))
    expect_included(argu_url("/m/#{motion.id}/cons", type: 'paginated'))
    expect_included(argu_url("/m/#{motion.id}/cons", page: 1, type: 'paginated'))
    expect_included(motion.pro_arguments.untrashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_included(motion.con_arguments.untrashed.map { |a| argu_url("/con/#{a.id}") })
    expect_not_included(motion.pro_arguments.trashed.map { |a| argu_url("/pro/#{a.id}") })
    expect_not_included(motion.con_arguments.trashed.map { |a| argu_url("/con/#{a.id}") })

    expect_relationship('attachmentCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/media_objects", filter: {used_as: 'attachment'}, type: 'paginated'))
    expect_included(motion.attachments.map { |r| argu_url("/media_objects/#{r.id}") })

    expect_relationship('voteEventCollection', 1)
    expect_included(argu_url("/m/#{motion.id}/vote_events", type: 'paginated'))
    expect_included(argu_url("/m/#{motion.id}/vote_events/#{motion.default_vote_event.id}"))
    expect_included(argu_url(motion_votes_base_path, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'yes'}, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'yes'}, page: 1, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'other'}, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'other'}, page: 1, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'no'}, type: 'paginated'))
    expect_included(argu_url(motion_votes_base_path, filter: {option: 'no'}, page: 1, type: 'paginated'))
    expect_included(
      motion.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/votes/#{v.id}") }
    )
    expect_not_included(
      motion.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/votes/#{v.id}") }
    )
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    get :index, params: {format: :json_api, forum_id: holland.id}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/#{holland.url}/m", page: 1, type: 'paginated'))
    expect_included(holland.motions.where(question_id: nil).untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  test 'should get index motions of forum page 1' do
    get :index, params: {format: :json_api, forum_id: holland.id, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal holland.motions.where(question_id: nil).untrashed.count,
                 expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count
    expect_included(holland.motions.where(question_id: nil).untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(holland.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, question_id: question.id}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/q/#{question.id}/m", page: 1, type: 'paginated'))
    expect_included(question.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end

  test 'should get index motions of question page 1' do
    get :index, params: {format: :json_api, question_id: question.id, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('memberSequence', question.motions.untrashed.count)
    expect_included(question.motions.untrashed.map { |m| argu_url("/m/#{m.id}") })
    expect_not_included(question.motions.trashed.map { |m| argu_url("/m/#{m.id}") })
  end
end

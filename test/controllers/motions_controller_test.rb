# frozen_string_literal: true

require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:question) { create(:question, :with_motions, parent: freetown.edge) }
  let(:question_motion) { create(:motion, :with_votes, parent: question.edge) }
  let(:motion) { create(:motion, :with_arguments, :with_votes, :with_attachments, parent: freetown.edge) }
  let(:vote_event) { motion.default_vote_event }

  ####################################
  # Show
  ####################################
  test 'should get show motion' do
    get :show, params: {format: :json_api, root_id: argu.id, id: motion.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('proArgumentCollection', 1)
    expect_relationship('conArgumentCollection', 1)
    expect_included(collection_iri(motion, :pro_arguments, type: 'paginated'))
    expect_included(collection_iri(motion, :pro_arguments, page: 1, type: 'paginated'))
    expect_included(collection_iri(motion, :con_arguments, type: 'paginated'))
    expect_included(collection_iri(motion, :con_arguments, page: 1, type: 'paginated'))
    expect_included(motion.pro_arguments.untrashed.map(&:iri))
    expect_included(motion.con_arguments.untrashed.map(&:iri))
    expect_not_included(motion.pro_arguments.trashed.map(&:iri))
    expect_not_included(motion.con_arguments.trashed.map(&:iri))

    expect_relationship('attachmentCollection', 1)
    expect_included(
      collection_iri(motion, :media_objects, CGI.escape('filter[used_as]') => 'attachment', type: 'paginated')
    )
    expect_included(motion.attachments.map(&:iri))

    expect_relationship('voteEventCollection', 1)
    expect_included(collection_iri(motion, :vote_events, type: 'paginated'))
    expect_included(vote_event.iri)
    expect_included(collection_iri(vote_event, :votes, type: 'paginated'))
    %w[yes other no].each do |side|
      expect_included(collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, type: 'paginated'))
      expect_included(
        collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated')
      )
    end
    expect_not_included(motion.votes.map(&:iri))
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    get :index, params: {format: :json_api, root_id: argu.id, forum_id: holland.id}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(collection_iri(holland, :motions, page: 1, type: 'paginated'))
    expect_included(holland.motions.where(question_id: nil).untrashed.map(&:iri))
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  test 'should get index motions of forum page 1' do
    get :index, params: {format: :json_api, root_id: argu.id, forum_id: holland.id, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal holland.motions.where(question_id: nil).untrashed.count,
                 expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count
    expect_included(holland.motions.where(question_id: nil).untrashed.map(&:iri))
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, root_id: argu.id, question_id: question.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(collection_iri(question, :motions, page: 1, type: 'paginated'))
    expect_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))
    expect_included(question.motions.untrashed.map { |m| m.default_vote_event.iri })
  end

  test 'should get index motions of question page 1' do
    get :index, params: {format: :json_api, root_id: argu.id, question_id: question.edge.fragment, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('memberSequence', question.motions.untrashed.count)
    expect_included(question.motions.untrashed.map(&:iri))
    expect_not_included(question.motions.trashed.map(&:iri))

    expect_included(question.motions.untrashed.map { |m| m.default_vote_event.iri })
    expect_not_included(question.motions.trashed.map { |m| m.default_vote_event.votes }.map(&:iri))
  end

  test 'should include current_vote in get index motions of question page 1' do
    user_vote = question_motion.default_vote_event.votes.first
    user = user_vote.publisher

    sign_in user

    get :index, params: {format: :json_api, root_id: argu.id, question_id: question.edge.fragment, page: 1}
    assert_response 200

    expect_included(user_vote.iri)
  end
end

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

    expect_relationship('parent')
    expect_relationship('creator')

    expect_relationship('pro_argument_collection')
    expect_relationship('con_argument_collection')
    expect_relationship('attachment_collection')
    expect_relationship('vote_event_collection')
  end

  ####################################
  # Index for Forum
  ####################################
  test 'should get index motions of forum' do
    ActsAsTenant.with_tenant(holland.parent) do
      get :index, params: {format: :json_api, parent_iri: parent_iri_for(holland)}
    end
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(collection_iri(holland, :motions, page: 1))
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  test 'should get index infinite motions of forum' do
    ActsAsTenant.with_tenant(holland.parent) do
      get :index, params: {
        format: :json_api,
        parent_iri: parent_iri_for(holland),
        type: :infinite
      }
    end
    assert_response 200

    expect_relationship('part_of')

    default_view = expect_default_view
    current_time = CGI.parse(default_view['id'])['before[]'].first.split('=').last
    expect_included(
      collection_iri(
        holland,
        :motions,
        type: :infinite,
        'before%5B%5D': %W[
          #{CGI.escape(NS::ARGU[:pinnedAt])}=#{LinkedRails::Collection::Sorting::DATE_TIME_MIN.iso8601(6)}
          #{CGI.escape(NS::ARGU[:lastActivityAt])}=#{current_time}
          #{CGI.escape(NS::ONTOLA[:primaryKey])}=-2147483648
        ]
      )
    )
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  test 'should get index motions of forum page 1' do
    ActsAsTenant.with_tenant(holland.parent) do
      get :index,
          params: {
            format: :json_api,
            parent_iri: parent_iri_for(holland),
            type: 'paginated',
            page: 1
          }
    end
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, holland.motions.untrashed.count)
    expect_not_included(question.motions.map(&:iri))
    expect_not_included(holland.motions.trashed.map(&:iri))
  end

  ####################################
  # Index for Question
  ####################################
  test 'should get index motions of question' do
    get :index, params: {format: :json_api, parent_iri: parent_iri_for(question)}
    assert_response 200

    expect_relationship('part_of')

    expect_view_members(expect_default_view, question.motions.active.count)
    expect_not_included(question.motions.trashed.map(&:iri))
  end

  test 'should get index motions of question page 1' do
    get :index,
        params: {format: :json_api, parent_iri: parent_iri_for(question), type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, question.motions.untrashed.count)
    expect_not_included(question.motions.trashed.map(&:iri))

    expect_not_included(question.motions.trashed.map { |m| m.default_vote_event.votes }.map(&:iri))
  end
end

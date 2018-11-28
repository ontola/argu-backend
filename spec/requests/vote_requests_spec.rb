# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Votes', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:destroy_differences) { {'Vote.count' => -1} }
  let(:update_differences) { {'Vote.count' => 0} }
  let(:destroy_path) { show_path }
  let(:show_by_parent_path) do
    expand_uri_template(:vote_iri, parent_iri: subject.parent.iri_path)
  end
  let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('403') }
  let(:expect_post_create_guest_serializer) { expect_created }
  let(:expect_get_show_guest_html) { expect_get_show_html }
  let(:guest_user) { GuestUser.new(id: session.id) }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_destroy) { subject.publisher }

  shared_examples_for 'by parent' do |opts = {skip: []}|
    let(:show_path) { show_by_parent_path }
    let(:expect_delete_destroy_guest_json_api) { expect(response.code).to eq('204') }
    let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('200') }
    let(:expect_delete_destroy_unauthorized_serializer) { expect_not_found }
    let(:expect_delete_destroy_unauthorized_html) { expect_not_found }
    let(:expect_get_show_unauthorized_serializer) { expect_not_found }
    let(:expect_get_show_unauthorized_html) { expect_not_found }
    it_behaves_like 'get show', opts
    it_behaves_like 'delete destroy', opts
  end

  context 'for argument' do
    let!(:subject) { argument_vote }
    let!(:guest_subject) do
      get root_path
      create(:vote, parent: subject.parent, creator: guest_user.profile, publisher: guest_user)
    end
    let(:expect_get_show_html) { expect(response).to redirect_to(subject.parent.iri_path) }
    let(:expect_redirect_to_login) { new_iri_path(subject.parent, :votes, confirm: true) }
    let(:created_resource_path) { subject.parent.iri_path }
    it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
    it_behaves_like 'by parent'
  end

  context 'with vote_event' do
    let(:parent_path) { subject.parent.iri_path }
    let(:update_path) { create_path }
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(subject.voteable.iri_path)
    end

    context 'for motion' do
      let!(:subject) { vote }
      let!(:guest_subject) do
        get root_path
        create(:vote, parent: motion.default_vote_event, creator: guest_user.profile, publisher: guest_user)
      end
      let(:expect_get_show_html) { expect(response).to redirect_to(motion.iri_path) }
      let(:expect_redirect_to_login) { new_iri_path(motion.default_vote_event, :votes, confirm: true) }
      let(:created_resource_path) { motion.iri_path }
      it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
      it_behaves_like 'by parent'
    end

    context 'for linked_record' do
      let!(:subject) { linked_record_vote }
      let(:parent_path) {}
      let!(:guest_subject) do
        get root_path
        create(:vote, parent: linked_record.default_vote_event, creator: guest_user.profile, publisher: guest_user)
      end
      let(:expect_get_show_html) { expect(response).to linked_record.iri_path }
      let(:expect_redirect_to_login) do
        new_iri_path(linked_record.default_vote_event.iri_path(id: 'default'), confirm: true)
      end
      let(:show_by_parent_path) do
        expand_uri_template(:vote_iri, parent_iri: subject.parent.iri_path, id: 'default')
      end
      let(:index_path) do
        collection_iri(subject.parent.iri_path(id: 'default'), :votes)
      end
      let(:non_existing_index_path) do
        collection_iri(subject.parent.iri_path(id: non_existing_id), :votes)
      end
      let(:created_resource_path) { linked_record.iri_path }
      it_behaves_like 'requests', skip: %i[trash untrash edit delete update new create_invalid html]
      it_behaves_like 'by parent', skip: %i[html]
    end

    context 'with non-persisted linked_record parent' do
      let(:create_guest_differences) do
        {
          'Argu::Redis.keys("temporary.*").count' => 1,
          'LinkedRecord.count' => 1,
          'VoteEvent.count' => 1
        }
      end
      let(:non_persisted_linked_record) do
        LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid)
      end
      subject { build(:vote, parent: non_persisted_linked_record) }
      let(:parent_path) {}
      let(:index_path) do
        collection_iri_path(non_persisted_linked_record.default_vote_event.iri_path(id: 'default'), :votes)
      end
      let(:non_existing_index_path) do
        collection_iri_path(
          expand_uri_template(
            :vote_events_iri,
            parent_iri: expand_uri_template(
              :linked_records_iri,
              organization: argu.url,
              forum: freetown.url,
              linked_record_id: non_existing_id
            ),
            id: 'default'
          ),
          :votes
        )
      end
      it_behaves_like 'post create', skip: %i[html]
      it_behaves_like 'get index', skip: %i[html]
    end
  end
end

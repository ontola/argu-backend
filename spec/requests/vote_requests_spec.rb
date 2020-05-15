# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Votes', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  before do
    freetown.update(public_grant: :participator)
  end

  let(:unauthorized_user) do
    freetown.grants.destroy_all
    create_forum(public_grant: 'participator', parent: create(:page))
    create(:user)
  end

  let(:destroy_differences) { {'Vote.count' => -1} }
  let(:update_differences) { {'Vote.count' => 0} }
  let(:destroy_path) { show_path }
  let(:show_by_parent_path) do
    expand_uri_template(:vote_iri, parent_iri: split_iri_segments(subject_parent.iri.path))
  end
  let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('403') }
  let(:expect_post_create_guest_serializer) { expect_created }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_destroy) { subject.publisher }

  shared_examples_for 'by parent' do |opts = {skip: []}|
    let(:show_path) { show_by_parent_path }
    let(:expect_delete_destroy_guest_json_api) { expect(response.code).to eq('204') }
    let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('200') }
    let(:expect_delete_destroy_unauthorized_serializer) { expect_not_found }
    let(:expect_get_show_unauthorized_serializer) { expect_success }
    it_behaves_like 'get show', opts
    it_behaves_like 'delete destroy', opts
  end

  context 'for argument' do
    let!(:subject) { argument_vote }
    let!(:guest_subject) do
      create(:vote, parent: subject_parent, creator: guest_user.profile, publisher: guest_user)
    end
    let(:expect_redirect_to_login) { new_iri(subject_parent, :votes, confirm: true) }
    let(:created_resource_path) { subject_parent.iri.path }

    it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
    it_behaves_like 'by parent'
  end

  context 'with vote_event' do
    let(:parent_path) { subject_parent.iri.path }
    let(:update_path) { create_path }

    context 'for motion' do
      let!(:subject) { vote }
      let!(:guest_subject) do
        create(:vote, parent: motion.default_vote_event, creator: guest_user.profile, publisher: guest_user)
      end
      let(:expect_redirect_to_login) { new_iri(motion.default_vote_event, :votes, confirm: true) }
      let(:created_resource_path) { motion.iri.path }

      it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
      it_behaves_like 'by parent'
    end
  end
end

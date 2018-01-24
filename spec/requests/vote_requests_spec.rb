# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Votes', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:destroy_differences) { [['Vote.count', -1]] }
  let(:update_differences) { [['Vote.count', 0]] }
  let(:update_params) { {vote: {explanation: 'explanation'}} }
  let(:show_path) { vote_path(subject) }
  let(:destroy_path) { show_path }
  let(:show_by_parent_path) do
    url_for([subject.voteable, subject.parent_model, :show, :vote, only_path: true])
  end
  let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('403') }
  let(:expect_post_create_guest_serializer) { expect_created }
  let(:expect_get_show_guest_html) { expect_get_show_html }
  let(:guest_user) { GuestUser.new(session: session) }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_destroy) { subject.publisher }

  shared_examples_for 'by parent' do |opts = {skip: []}|
    let(:show_path) { show_by_parent_path }
    let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('204') }
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
      create(:vote, parent: argument.edge, creator: guest_user.profile, publisher: guest_user)
    end
    let(:show_by_parent_path) do
      url_for([subject.parent_model, :vote, only_path: true])
    end
    let(:expect_get_show_html) { expect(response).to redirect_to(argument) }
    let(:expect_redirect_to_login) { new_argument_vote_path(argument, confirm: true) }
    let(:created_resource_path) { argument_path(argument) }
    it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
    it_behaves_like 'by parent'
  end

  context 'with vote_event' do
    let(:parent_path) { url_for([subject.voteable, subject.parent_model, only_path: true]) }
    let(:index_path) { url_for([subject.voteable, subject.parent_model, table_sym, only_path: true]) }
    let(:new_path) { url_for([:new, subject.voteable, subject.parent_model, class_sym, only_path: true]) }
    let(:show_by_parent_path) { url_for([subject.voteable, subject.parent_model, :vote, only_path: true]) }
    let(:update_path) { url_for([subject.voteable, subject.parent_model, :votes, only_path: true]) }
    let(:non_existing_new_path) do
      url_for([:new, :motion, parent_class_sym, class_sym, vote_event_id: -1, motion_id: motion.id, only_path: true])
    end
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(subject.voteable)
    end

    context 'for motion' do
      let!(:subject) { vote }
      let!(:guest_subject) do
        get root_path
        create(:vote, parent: motion.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
      end
      let(:expect_get_show_html) { expect(response).to redirect_to(motion) }
      let(:expect_redirect_to_login) do
        new_motion_vote_event_vote_path(motion, motion.default_vote_event, confirm: true)
      end
      let(:non_existing_index_path) do
        url_for([:motion, :vote_event, :votes, vote_event_id: -1, motion_id: motion.id, only_path: true])
      end
      let(:created_resource_path) { motion_path(motion) }
      it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid]
      it_behaves_like 'by parent'
    end

    context 'for linked_record' do
      let!(:subject) { linked_record_vote }
      let(:parent_path) {}
      let!(:guest_subject) do
        get root_path
        create(:vote, parent: linked_record.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
      end
      let(:expect_get_show_html) { expect(response).to redirect_to(linked_record) }
      let(:expect_redirect_to_login) do
        new_linked_record_vote_event_vote_path(linked_record, linked_record.default_vote_event, confirm: true)
      end
      let(:show_by_parent_path) do
        linked_record_vote_event_vote_path(
          organization: argu.url,
          forum: freetown.url,
          linked_record_id: linked_record.deku_id,
          vote_event_id: 'default'
        )
      end
      let(:index_path) do
        linked_record_vote_event_votes_path(
          organization: argu.url,
          forum: freetown.url,
          linked_record_id: linked_record.deku_id,
          vote_event_id: 'default'
        )
      end
      let(:non_existing_index_path) do
        linked_record_vote_event_votes_path(
          organization: argu.url,
          forum: freetown.url,
          linked_record_id: -1,
          vote_event_id: 'default'
        )
      end
      let(:created_resource_path) { linked_record_path(linked_record) }
      it_behaves_like 'requests', skip: %i[trash untrash edit delete update create_invalid html]
      it_behaves_like 'by parent', skip: %i[html]
    end

    context 'with non-persisted linked_record parent' do
      let(:non_persisted_linked_record) do
        LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid)
      end
      subject { build(:vote, edge: Edge.new(parent: non_persisted_linked_record.edge)) }
      let(:parent_path) {}
      let(:index_path) do
        linked_record_vote_event_votes_path(
          organization: argu.url,
          forum: freetown.url,
          linked_record_id: SecureRandom.uuid,
          vote_event_id: 'default'
        )
      end
      let(:non_existing_index_path) do
        linked_record_vote_event_votes_path(
          organization: argu.url,
          forum: freetown.url,
          linked_record_id: -1,
          vote_event_id: 'default'
        )
      end
      it_behaves_like 'post create', skip: %i[html]
      it_behaves_like 'get index', skip: %i[html]
    end
  end
end

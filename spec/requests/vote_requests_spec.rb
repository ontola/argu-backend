# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Votes', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:destroy_differences) { [['Vote.count', -1]] }
  let(:update_differences) { [['Vote.count', 0]] }
  let(:expect_redirect_to_login) { new_motion_vote_path(motion, confirm: true) }
  let(:update_params) { {vote: {explanation: 'explanation'}} }
  let(:created_resource_path) { motion_path(motion) }
  let(:show_path) { vote_path(subject) }
  let(:destroy_path) { url_for([subject.parent_model, :votes, only_path: true]) }
  let(:update_path) { url_for([subject.parent_model, :votes, only_path: true]) }
  let(:expect_post_create_guest_json_api) { expect_created }
  let(:expect_delete_destroy_guest_json_api) { expect(response.code).to eq('204') }
  let(:expect_delete_destroy_unauthorized_json_api) { expect_not_found }
  let(:expect_delete_destroy_unauthorized_html) { expect_not_found }
  let(:expect_get_show_html) { expect(response).to redirect_to(motion.default_vote_event) }
  let(:expect_get_show_guest_html) { expect_get_show_html }

  let!(:subject) { vote }
  let(:guest_user) { GuestUser.new(session: session) }
  let!(:guest_subject) do
    get root_path
    create(:vote, parent: motion.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:authorized_user_update) { subject.publisher }

  shared_examples_for 'show by parent' do
    let(:show_path) { url_for([subject.parent_model, :show, :vote, only_path: true]) }
    %i[html json_api n3].each do |format|
      context "as #{format}" do
        let(:expect_get_show_unauthorized_json_api) { expect_not_found }
        let(:expect_get_show_unauthorized_html) { expect_not_found }
        let(:request_format) { format }
        it_behaves_like 'get show'
      end
    end
  end

  context 'for motion' do
    it_behaves_like 'requests', skip: %i[html_index trash untrash edit delete update create_invalid]
    it_behaves_like 'show by parent'
  end

  context 'for argument' do
    let!(:subject) { argument_vote }
    let!(:guest_subject) do
      get root_path
      create(:vote, parent: argument.edge, creator: guest_user.profile, publisher: guest_user)
    end
    let(:expect_get_show_html) { expect(response).to redirect_to(argument) }
    let(:expect_redirect_to_login) { new_argument_vote_path(argument, confirm: true) }
    let(:created_resource_path) { argument_path(argument) }
    it_behaves_like 'requests', skip: %i[html_index trash untrash edit delete update create_invalid]
    it_behaves_like 'show by parent'
  end

  context 'for linked_record' do
    let!(:subject) { linked_record_vote }
    let!(:guest_subject) do
      get root_path
      create(:vote, parent: linked_record.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
    end
    let(:expect_get_show_html) { expect(response).to redirect_to(linked_record.default_vote_event) }
    let(:expect_redirect_to_login) { new_linked_record_vote_path(linked_record, confirm: true) }
    let(:created_resource_path) { linked_record_path(linked_record) }
    it_behaves_like 'requests', skip: %i[html_index trash untrash edit delete update create_invalid]
    it_behaves_like 'show by parent'
  end
end

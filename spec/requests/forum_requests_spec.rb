# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Forums', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:authorized_user) { staff }

  let(:index_path) { collection_iri(subject.parent, :forums).path }
  let(:create_params) { {forum: attributes_for(class_sym).merge(url: 'new_forum')} }
  let(:create_differences) { {'Forum.count' => 1} }
  let(:invalid_create_params) { {page_id: argu.url, forum: {name: 'n1'}} }
  let(:update_params) { {page_id: argu.url, forum: {name: 'name'}} }
  let(:invalid_update_params) { {page_id: argu.url, forum: {name: 'n1'}} }
  let(:destroy_params) { {forum: {confirmation_string: 'remove'}} }
  let(:table_sym) { :container_nodes }

  let(:expect_post_create_failed_html) do
    expect_success
    expect(response.body).to(include('n1'))
  end

  let(:expect_put_update_failed_html) { expect_post_create_failed_html }
  let(:expect_put_update_html) do
    expect(response).to redirect_to(updated_resource_path)
    subject.reload
    expect(subject.name).to eq('name')
  end

  let(:update_differences) { {'Forum.count' => 0} }
  let(:destroy_differences) { {'Forum.count' => -1} }

  context 'with public forum' do
    subject { freetown }
    it_behaves_like 'requests', skip: %i[trash untrash index show_unauthorized]
  end

  context 'with hidden forum' do
    subject { holland }

    let(:expect_get_show_guest_html) { expect_not_found }
    let(:expect_get_show_guest_serializer) { expect_not_found }
    let(:expect_unauthorized) { expect_not_found }

    it_behaves_like 'requests', skip: %i[trash untrash index new create]
  end
end

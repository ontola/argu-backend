# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Forums', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:authorized_user) { staff }

  let(:invalid_create_params) { {page_id: argu.url, forum: {name: 'n1'}} }
  let(:update_params) { {page_id: argu.url, forum: {name: 'name'}} }
  let(:invalid_update_params) { {page_id: argu.url, forum: {name: 'n1'}} }
  let(:destroy_params) { {forum: {confirmation_string: 'remove'}} }

  let(:edit_path) { settings_iri_path(subject) }
  let(:non_existing_edit_path) { settings_iri_path(non_existing_id) }
  let(:updated_resource_path) { settings_iri_path(subject, tab: :general) }

  let(:expect_get_show_guest_html) { expect_not_found }
  let(:expect_get_show_guest_serializer) { expect_not_found }
  let(:expect_unauthorized) { expect_not_found }
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

  subject { holland }
  it_behaves_like 'requests', skip: %i[trash untrash new create index]

  context 'portal routes' do
    let(:expect_redirect_to_login) { expect_not_found }
    let(:new_path) { new_portal_forum_path(page_id: argu.url) }
    let(:non_existing_new_path) { new_portal_forum_path(page_id: non_existing_id) }
    let(:create_path) { portal_forums_path }
    let(:non_existing_create_path) { portal_forums_path(page_id: non_existing_id) }
    let(:create_params) do
      nominatim_netherlands
      {page_id: argu.url, forum: {name: 'name', url: 'new_forum'}}
    end
    let(:create_differences) { {'Forum.count' => 1} }
    let(:expect_post_create_guest_serializer) { expect_not_found }
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end
end

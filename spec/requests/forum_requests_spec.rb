# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Forums', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:authorized_user) { staff }
  let(:invalid_create_params) { {forum: {page_id: argu.id, name: 'n1'}} }
  let(:update_differences) { [['Forum.count', 0]] }
  let(:destroy_differences) { [['Forum.count', -1]] }
  let(:edit_path) { settings_forum_path(subject) }
  let(:non_existing_edit_path) { settings_forum_path(-99) }
  let(:expect_get_show_guest_html) { expect_not_found }
  let(:expect_get_show_guest_serializer) { expect_not_found }
  let(:updated_resource_path) { settings_forum_path(subject, tab: :general) }
  let(:expect_unauthorized) { expect_not_found }
  let(:update_params) { {forum: {page_id: argu.id, name: 'name'}} }
  let(:invalid_update_params) { {forum: {page_id: argu.id, name: 'n1'}} }
  let(:expect_post_create_failed_html) do
    expect_success
    expect(response.body).to(include('n1'))
  end
  let(:expect_put_update_failed_html) { expect_post_create_failed_html }
  let(:destroy_params) { {forum: {confirmation_string: 'remove'}} }

  subject { holland }
  it_behaves_like 'requests', skip: %i[trash untrash new create index]

  context 'portal routes' do
    let(:expect_redirect_to_login) { expect_not_found }
    let(:new_path) { new_portal_forum_path(forum: {page_id: -99}) }
    let(:non_existing_new_path) { new_portal_forum_path(forum: {page_id: -99}) }
    let(:create_path) { portal_forums_path }
    let(:non_existing_create_path) { portal_forums_path(forum: {page_id: -99}) }
    let(:create_params) do
      nominatim_netherlands
      {forum: {page_id: argu.id, name: 'name', shortname_attributes: {shortname: 'new_forum'}}}
    end
    let(:create_differences) { [['Forum.count', 1]] }
    let(:expect_post_create_guest_serializer) { expect_not_found }
    let(:expect_get_new) { expect_not_found }
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end
end

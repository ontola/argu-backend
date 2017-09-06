# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Sources', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:authorized_user) { staff }
  let(:invalid_create_params) { {source: {page_id: argu.id, name: 'n1'}} }
  let(:update_differences) { [['Source.count', 0]] }
  let(:destroy_differences) { [['Source.count', -1]] }
  let(:edit_path) { settings_page_source_path(argu, subject) }
  let(:non_existing_edit_path) { settings_page_source_path(argu, -1) }
  let(:updated_resource_path) { settings_page_source_path(argu, subject, tab: :general) }
  let(:update_params) { {source: {page_id: argu.id, name: 'name'}} }
  let(:invalid_update_params) { {source: {page_id: argu.id, name: 'n1'}} }
  let(:show_path) { page_source_path(argu, subject) }
  let(:non_existing_show_path) { page_source_path(argu, -1) }
  let(:update_path) { page_source_path(argu, subject) }
  let(:non_existing_update_path) { page_source_path(argu, '-1') }
  let(:destroy_path) { page_source_path(argu, subject) }
  let(:non_existing_destroy_path) { page_source_path(argu, '-1') }
  let(:expect_post_create_failed_html) do
    expect_success
    expect(response.body).to(include('n1'))
  end
  let(:expect_put_update_failed_html) { expect_post_create_failed_html }
  let(:expect_get_show_html) { expect(response).to redirect_to(settings_page_source_path(argu, subject)) }

  subject { public_source }
  it_behaves_like 'requests', skip: %i[trash untrash delete destroy new create index]

  context 'portal routes' do
    let(:expect_redirect_to_login) { expect_not_found }
    let(:new_path) { new_portal_source_path(source: {page_id: -1}) }
    let(:non_existing_new_path) { new_portal_source_path(source: {page_id: -1}) }
    let(:create_path) { portal_sources_path }
    let(:non_existing_create_path) { portal_sources_path(source: {page_id: -1}) }
    let(:create_params) do
      nominatim_netherlands
      {source: {page_id: argu.id, name: 'name', shortname: 'new_source', iri_base: 'https://iri.new'}}
    end
    let(:create_differences) { [['Source.count', 1]] }
    let(:created_resource_path) { page_source_path(argu, Source.last) }
    let(:expect_post_create_guest_json_api) { expect_not_found }
    let(:expect_get_new) { expect_not_found }
    let(:expect_unauthorized) { expect_not_found }
    it_behaves_like 'get new'
    %i[html json_api n3].each do |format|
      context "as #{format}" do
        let(:request_format) { format }
        it_behaves_like 'post create'
      end
    end
  end
end

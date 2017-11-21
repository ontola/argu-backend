# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Pages', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:edit_path) do
    nominatim_netherlands
    settings_page_path(subject)
  end
  let(:non_existing_edit_path) { settings_page_path(-1) }
  let(:non_existing_new_path) { new_page_path(-1) }
  let(:expect_get_show_unauthorized_json_api) { expect_success }
  let(:expect_get_show_unauthorized_html) { expect_success }
  let(:create_differences) { [['Page.count', 1]] }
  let(:update_differences) { [['Page.count', 0]] }
  let(:destroy_differences) { [['Page.count', -1]] }
  let(:updated_resource_path) { settings_page_path(subject, tab: :profile) }
  let(:parent_path) { subject }
  let(:created_resource_path) { settings_page_path(Page.last, tab: :profile) }
  let(:create_failed_path) { new_page_path }
  let(:create_params) do
    {page: {profile_attributes: {name: 'name'}, shortname_attributes: {shortname: 'new_page'}, last_accepted: '1'}}
  end
  let(:invalid_create_params) { {page: {profile_attributes: {name: 'new_name'}}} }
  let(:update_params) { {page: {profile_attributes: {id: subject.profile.id, name: 'new_name'}}} }
  let(:invalid_update_params) do
    nominatim_netherlands
    {page: {last_accepted: nil}}
  end
  let(:expect_put_update_html) do
    expect(response).to redirect_to(updated_resource_path)
    expect(subject.reload.display_name).to eq('new_name')
  end
  let(:expect_put_update_failed_html) { expect_success }
  let(:expect_post_create_failed_html) do
    expect_success
    expect(response.body).to(include('new_name'))
  end
  let(:destroy_params) { {page: {confirmation_string: 'remove'}} }
  let(:authorized_user) { create_administrator(subject, create(:user)) }
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(root_path)
  end

  context 'public page' do
    subject { create(:page) }
    let(:request_format) { :html }
    it_behaves_like 'requests', skip: %i[
      trash untrash new_unauthorized new_non_existing create_non_existing
      create_unauthorized index_non_existing html_index index_unauthorized
    ]
  end
end

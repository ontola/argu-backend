# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:authorized_user) { create_administrator(subject, create(:user)) }
  let(:edit_path) do
    nominatim_netherlands
    settings_iri(subject).path
  end
  let(:index_path) { collection_iri(argu, table_sym).path }
  let(:non_existing_show_path) { '/non_existing' }
  let(:non_existing_destroy_path) { non_existing_show_path }
  let(:non_existing_edit_path) { settings_iri(non_existing_show_path, root: argu).path }
  let(:parent_path) { subject.iri.path }
  let(:updated_resource_path) { "#{settings_iri(subject).path}?tab=profile" }
  let(:created_resource_path) { "#{settings_iri(Page.last).path}?tab=profile" }
  let(:create_failed_path) { new_iri(argu, :pages).path }
  let(:create_differences) { {'Page.count' => 1} }
  let(:update_differences) { {'Page.count' => 0} }
  let(:destroy_differences) { {'Page.count' => -1} }
  let(:create_params) do
    {
      page: {
        profile_attributes: {name: 'name'},
        url: 'new_page',
        last_accepted: '1'
      }
    }
  end
  let(:invalid_create_params) { {page: {profile_attributes: {name: 'new_name'}}} }
  let(:update_params) { {page: {profile_attributes: {id: subject.profile.id, name: 'new_name'}}} }
  let(:invalid_update_params) do
    nominatim_netherlands
    {page: {profile_attributes: {name: 'a'}}}
  end
  let(:destroy_params) { {page: {confirmation_string: 'remove'}} }
  let(:expect_get_show_unauthorized_serializer) { expect_success }
  let(:expect_get_show_unauthorized_html) { expect_success }
  let(:expect_put_update_html) do
    expect(response).to redirect_to(updated_resource_path)
    expect(subject.reload.display_name).to eq('new_name')
  end
  let(:expect_put_update_failed_html) { expect_success }
  let(:expect_put_update_json_api) { expect(response.code).to eq('204') }
  let(:expect_post_create_failed_html) do
    expect_success
    expect(response.body).to(include('new_name'))
  end
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(root_path)
  end
  let(:expect_post_create_json_api) { expect_created }
  let(:expect_post_create_serializer) { expect_success }
  let(:expect_get_form_guest_serializer) { expect_get_form_serializer }
  let(:expect_get_form_unauthorized_serializer) { expect_get_form_serializer }
  let(:expect_get_form_unauthorized_json_api) { expect_unauthorized }

  context 'public page' do
    subject { create_page }
    it_behaves_like 'requests', skip: %i[
      trash untrash new_unauthorized new_non_existing create_non_existing
      create_unauthorized index_non_existing index_unauthorized
    ]
    context 'user pages' do
      let(:index_path) { "/#{argu.url}#{pages_user_path(authorized_user)}" }
      let(:non_existing_index_path) { "/#{argu.url}#{pages_user_path(non_existing_id)}" }
      let(:expect_get_index_guest_html) { expect(response.code).to eq('302') }
      let(:expect_get_index_guest_serializer) { expect(response.code).to eq('401') }
      it_behaves_like 'get index'
    end
  end
end

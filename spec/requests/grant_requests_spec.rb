# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Grants', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.show_formats
    super - %i[html]
  end

  def self.new_formats
    %i[html]
  end

  let(:create_differences) { {"#{subject.class}.count" => 1} }
  let(:update_differences) { {"#{subject.class}.count" => 0} }
  let(:destroy_differences) { {"#{subject.class}.count" => -1} }

  let(:index_path) { collection_iri(subject_parent.root, table_sym).path }
  let(:created_resource_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:group) { create(:group, parent: argu) }
  let(:create_params) { {grant: attributes_for(:group).merge(group_id: create(:group, parent: argu).id)} }
  let(:create_failed_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:update_failed_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to("#{settings_iri(argu)}?tab=groups")
  end

  context 'with page parent' do
    let(:subject) { create(:grant, edge: argu, group: group) }
    let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
    it_behaves_like 'requests', skip: %i[trash untrash edit update show_html delete index]
  end

  context 'with forum parent' do
    let(:subject) { create(:grant, edge: freetown, group: group) }
    it_behaves_like 'requests', skip: %i[trash untrash edit update show_html delete index]
  end
end

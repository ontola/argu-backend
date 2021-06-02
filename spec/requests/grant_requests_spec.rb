# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Grants', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:create_differences) { {"#{subject.class}.count" => 1} }
  let(:update_differences) { {"#{subject.class}.count" => 0} }
  let(:destroy_differences) { {"#{subject.class}.count" => -1} }

  let(:created_resource_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:group) { create(:group, parent: argu) }
  let(:create_params) { {grant: attributes_for(:grant).merge(group_id: create(:group, parent: argu).id)} }
  let(:create_failed_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:update_failed_path) { "#{settings_iri(argu).path}?tab=groups" }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:subject) { create(:grant, edge: argu, group: group) }

  context 'with page parent' do
    let(:non_existing_index_path) { '/non_existing/grants' }
    let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }

    it_behaves_like 'requests', skip: %i[trash untrash new edit update delete index]
  end

  context 'with forum parent' do
    let(:subject) { create(:grant, edge: freetown, group: group) }
    let(:index_path) { collection_iri(subject_parent.root, table_sym).path }

    it_behaves_like 'requests', skip: %i[trash untrash new edit update delete index]
  end

  context 'with group parent' do
    let(:subject_parent) { group }
    let(:create_params) { {grant: attributes_for(:grant).merge(edge_id: freetown.uuid)} }
    let(:index_path) { collection_iri(subject_parent, table_sym).path }

    it_behaves_like 'requests', skip: %i[trash untrash new edit update delete index]
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Favorites', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:non_existing_destroy_path) { non_existing_index_path }
  let(:destroy_path) { index_path }
  let(:update_failed_path) { index_path }
  let(:created_resource_path) { holland.iri_path }
  let(:create_differences) { {'Favorite.count' => 1} }
  let(:destroy_differences) { {'Favorite.count' => -1} }
  let(:create_params) { {} }
  let(:authorized_user) { staff }
  let(:expect_delete_destroy_unauthorized_html) { expect_not_found }
  let(:expect_delete_destroy_unauthorized_serializer) { expect_not_found }
  let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
  let(:root_id) { holland.parent.url }
  subject { create(:favorite, user: staff, edge: holland) }
  it_behaves_like 'post create', skip: %i[create_invalid]
  it_behaves_like 'delete destroy'

  context 'for motion iri' do
    let(:create_path) { url_for([:favorites, only_path: true, iri: holland.motions.first.iri, root_id: root_id]) }
    it_behaves_like 'post create', skip: %i[create_invalid]
  end

  context 'for motion canonical' do
    let(:create_path) do
      url_for([:favorites, only_path: true, iri: holland.motions.first.canonical_iri, root_id: root_id])
    end
    it_behaves_like 'post create', skip: %i[create_invalid]
  end

  context 'for forum iri' do
    let(:create_path) { url_for([:favorites, only_path: true, iri: holland.iri, root_id: root_id]) }
    it_behaves_like 'post create', skip: %i[create_invalid]
  end

  context 'for forum canonical' do
    let(:create_path) { url_for([:favorites, only_path: true, iri: holland.canonical_iri, root_id: root_id]) }
    it_behaves_like 'post create', skip: %i[create_invalid]
  end
end

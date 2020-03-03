# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  subject do
    holland.update!(discoverable: true)
    create(:favorite, user: staff, edge: holland)
  end

  let(:non_existing_destroy_path) { non_existing_index_path }
  let(:destroy_path) { index_path }
  let(:update_failed_path) { index_path }
  let(:created_resource_path) { holland.iri.path }
  let(:create_differences) { {'Favorite.count' => 1} }
  let(:destroy_differences) { {'Favorite.count' => -1} }
  let(:create_params) { {} }
  let(:authorized_user) { staff }
  let(:expect_delete_destroy_unauthorized_serializer) { expect_not_found }
  let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
  let(:root_id) { holland.parent.url }

  it_behaves_like 'post create', skip: %i[create_invalid]
  it_behaves_like 'delete destroy'

  context 'with iri' do
    let(:create_path) do
      "#{collection_iri(nil, :favorites, root: argu)}?iri=#{favorable_iri}"
    end

    context 'for motion iri' do
      let(:favorable_iri) { holland.motions.first.iri }

      it_behaves_like 'post create', skip: %i[create_invalid]
    end

    context 'for motion canonical' do
      let(:favorable_iri) { holland.motions.first.canonical_iri }

      it_behaves_like 'post create', skip: %i[create_invalid]
    end

    context 'for forum iri' do
      let(:favorable_iri) { holland.iri }

      it_behaves_like 'post create', skip: %i[create_invalid]
    end

    context 'for forum canonical' do
      let(:favorable_iri) { holland.canonical_iri }

      it_behaves_like 'post create', skip: %i[create_invalid]
    end
  end
end

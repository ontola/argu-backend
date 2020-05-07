# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Banners', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:update_path) { destroy_path }
  let(:create_failed_path) { settings_iri_path(argu, tab: :banners) }
  let(:updated_resource_path) { settings_iri_path(argu, tab: :banners) }
  let(:update_failed_path) { edit_path }
  let(:non_existing_index_path) { '/non_existing/banners' }
  let(:invalid_create_params) { {banner: {description: ''}} }
  let(:update_params) { {banner: {description: 'banner', audience: 'guests'}} }
  let(:created_resource_path) { settings_iri_path(freetown, tab: :banners) }
  let(:create_differences) do
    subject
    {'Banner.count' => 1}
  end
  let(:update_differences) do
    subject
    {'Banner.count' => 0}
  end
  let(:destroy_differences) do
    subject
    {'Banner.count' => -1}
  end

  context 'with page parent' do
    subject do
      create(
        :banner,
        audience: Banner.audiences[:everyone],
        parent: argu,
        content: 'content'
      )
    end

    it_behaves_like 'requests', skip: %i[trash untrash show_unauthorized index_unauthorized]
  end
end

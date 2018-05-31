# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Grants', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.show_formats
    super - %i[html]
  end

  let(:create_differences) { [["#{subject.class}.count", 1]] }
  let(:update_differences) { [["#{subject.class}.count", 0]] }
  let(:destroy_differences) { [["#{subject.class}.count", -1]] }

  let(:index_path) { collection_iri_path(subject.parent_model.root, table_sym) }
  let(:created_resource_path) { settings_iri_path(argu, tab: :groups) }
  let(:group) { create(:group, parent: argu) }
  let(:create_params) { {grant: attributes_for(:group).merge(group_id: create(:group, parent: argu).id)} }
  let(:create_failed_path) { settings_iri_path(argu, tab: :groups) }
  let(:update_failed_path) { settings_iri_path(argu, tab: :groups) }
  let(:expect_delete_destroy_serializer) { expect(response.code).to eq('204') }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }

  context 'with page parent' do
    let(:subject) { create(:grant, edge: argu, group: group) }
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(settings_iri_path(argu, tab: :groups))
    end
    it_behaves_like 'requests', skip: %i[trash untrash edit update show_html delete index]
  end

  context 'with forum parent' do
    let(:subject) { create(:grant, edge: freetown, group: group) }
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(settings_iri_path(freetown))
    end
    let(:update_failed_path) { settings_iri_path(freetown) }
    it_behaves_like 'requests', skip: %i[trash untrash edit update show_html delete index]
  end
end

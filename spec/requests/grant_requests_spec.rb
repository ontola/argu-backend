# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Grants', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:create_differences) { [["#{subject.class}.count", 1]] }
  let(:update_differences) { [["#{subject.class}.count", 0]] }
  let(:destroy_differences) { [["#{subject.class}.count", -1]] }

  let(:create_path) { page_grants_path(freetown.page) }
  let(:non_existing_create_path) { page_grants_path('non_existing') }
  let(:new_path) { new_page_grant_path(freetown.page) }
  let(:non_existing_new_path) { new_page_grant_path('non_existing') }
  let(:created_resource_path) { settings_page_path(freetown.page, tab: :groups) }
  let(:parent_path) { page_path(freetown.page) }
  let(:group) { create(:group, parent: freetown.page.edge) }
  let(:create_params) { {grant: attributes_for(:group).merge(group_id: create(:group, parent: freetown.page.edge).id)} }
  let(:create_failed_path) { settings_page_path(freetown.page, tab: :groups) }
  let(:update_failed_path) { settings_page_path(freetown.page, tab: :groups) }
  let(:expect_delete_destroy_serializer) { expect(response.code).to eq('204') }

  context 'with page parent' do
    let(:subject) { create(:grant, edge: freetown.page.edge, group: group) }
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(settings_page_path(freetown.page, tab: :groups))
    end
    it_behaves_like 'requests', skip: %i[trash untrash edit update show delete index]
  end

  context 'with forum parent' do
    let(:subject) { create(:grant, edge: freetown.edge, group: group) }
    let(:expect_delete_destroy_html) do
      expect(response.code).to eq('303')
      expect(response).to redirect_to(settings_forum_path(freetown))
    end
    let(:update_failed_path) { settings_forum_path(freetown) }
    it_behaves_like 'requests', skip: %i[trash untrash edit update show delete index]
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Exports', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:destroy_path) { url_for([:destroy, subject.edge, subject, destroy: true, only_path: true]) }
  let(:delete_path) { url_for([:delete, subject.edge, subject, destroy: true, only_path: true]) }
  let(:non_existing_destroy_path) { url_for([:destroy, subject.edge, :export, id: -1, destroy: true, only_path: true]) }
  let(:non_existing_delete_path) { url_for([:delete, subject.edge, :export, id: -1, destroy: true, only_path: true]) }
  let(:index_path) { url_for([subject.edge, :exports, only_path: true]) }
  let(:parent_path) { index_path }
  let(:created_resource_path) { index_path }
  let(:create_failed_path) { index_path }
  let(:destroy_failed_path) { index_path }
  let(:create_differences) { [['Export.count', 1]] }
  let(:destroy_differences) { [['Export.count', -1]] }
  let(:expect_get_index_guest_html) { expect(response.code).to eq('302') }
  let(:expect_get_index_guest_serializer) { expect_not_a_user }

  context 'with forum parent' do
    subject { forum_export }
    it_behaves_like 'requests', skip: %i[new edit update trash untrash show invalid]
  end

  context 'with motion parent' do
    subject { motion_export }
    it_behaves_like 'requests', skip: %i[new edit update trash untrash show invalid]
  end
end

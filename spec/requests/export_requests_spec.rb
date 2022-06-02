# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exports', type: :request do
  def self.new_formats
    default_formats - %i[json_api]
  end

  include Argu::TestHelpers::AutomatedRequests
  let(:index_path) { subject_parent.collection_iri(table_sym).path }
  let(:parent_path) { index_path }
  let(:created_resource_path) { parent_path }
  let(:destroy_failed_path) { parent_path }
  let(:create_differences) { {'Export.count' => 1} }
  let(:destroy_differences) { {'Export.count' => -1} }
  let(:expect_get_index_guest_serializer) { expect_unauthorized }
  let(:non_existing_id) { SecureRandom.uuid }
  let(:expect_get_form_guest_serializer) { expect_unauthorized }
  let(:expect_get_form_unauthorized_serializer) { expect_unauthorized }
  let(:expect_get_new_guest_serializer) { expect_success }
  let(:expect_get_new_unauthorized_serializer) { expect_success }

  context 'with page parent' do
    subject { page_export }

    it_behaves_like 'requests', skip: %i[edit update trash untrash show invalid]
  end

  context 'with forum parent' do
    subject { forum_export }

    it_behaves_like 'requests', skip: %i[edit update trash untrash show invalid]
  end

  context 'with motion parent' do
    subject { motion_export }

    it_behaves_like 'requests', skip: %i[edit update trash untrash show invalid]
  end
end

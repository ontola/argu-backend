# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exports', type: :request do
  def self.new_formats
    default_formats - %i[json_api html]
  end

  include Argu::TestHelpers::AutomatedRequests
  let(:index_path) { collection_iri(subject_parent.iri.path, table_sym).path }
  let(:parent_path) { index_path }
  let(:created_resource_path) { parent_path }
  let(:destroy_failed_path) { parent_path }
  let(:create_differences) { {'Export.count' => 1} }
  let(:destroy_differences) { {'Export.count' => -1} }
  let(:expect_get_index_guest_html) { expect(response.code).to eq('302') }
  let(:expect_get_index_guest_serializer) { expect_not_a_user }
  let(:non_existing_id) { SecureRandom.uuid }

  context 'with forum parent' do
    subject { forum_export }
    it_behaves_like 'requests', skip: %i[edit update trash untrash show invalid]
  end

  context 'with motion parent' do
    subject { motion_export }
    it_behaves_like 'requests', skip: %i[edit update trash untrash show invalid]
  end
end

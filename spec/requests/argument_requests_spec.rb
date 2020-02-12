# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:class_sym) { :pro_argument }
  let(:table_sym) { :pro_arguments }
  let(:update_params) { {pro_argument: Hash[required_keys.map { |k| [k, '12345'] }]} }
  let(:invalid_update_params) { {pro_argument: Hash[required_keys.map { |k| [k, ' '] }]} }
  let(:create_differences) { {"#{subject.class}.count" => 1, 'Activity.count' => 1} }

  context 'with motion parent' do
    subject { argument }

    let(:created_resource_path) { parent_path }

    it_behaves_like 'requests'
  end

  context 'with linked record parent' do
    subject { linked_record_argument }

    let(:parent_path) {}

    it_behaves_like 'requests', skip: %i[new]
  end

  context 'with non-persisted linked_record parent' do
    subject { build(:argument, parent: non_persisted_linked_record) }

    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }

    let(:parent_path) {}

    it_behaves_like 'post create'
    it_behaves_like 'get index'
  end
end

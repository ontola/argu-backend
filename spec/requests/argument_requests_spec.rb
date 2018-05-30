# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end
  let(:class_sym) { :pro_argument }
  let(:table_sym) { :pro_arguments }
  let(:update_params) { {pro_argument: Hash[required_keys.map { |k| [k, '12345'] }]} }
  let(:invalid_update_params) { {pro_argument: Hash[required_keys.map { |k| [k, '1'] }]} }
  let(:expect_put_update_html) do
    expect(response).to redirect_to(updated_resource_path)
    subject.reload
    update_params[:pro_argument].each { |k, v| expect(subject.send(k)).to eq(v) }
  end
  let(:expect_put_update_failed_html) do
    expect_success
    invalid_update_params[:pro_argument].each_value { |v| expect(response.body).to(include(v)) }
  end

  context 'with motion parent' do
    subject { argument }
    let(:created_resource_path) { parent_path }
    it_behaves_like 'requests'
  end

  context 'with linked record parent' do
    subject { linked_record_argument }
    let(:parent_path) {}
    it_behaves_like 'requests', skip: %i[new html]
  end

  context 'with non-persisted linked_record parent' do
    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
    subject { build(:argument, parent: non_persisted_linked_record) }
    let(:parent_path) {}
    it_behaves_like 'post create', skip: %i[html]
    it_behaves_like 'get index', skip: %i[html]
  end
end

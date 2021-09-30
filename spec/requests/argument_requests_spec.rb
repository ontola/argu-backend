# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:class_sym) { :pro_argument }
  let(:table_sym) { :pro_arguments }
  let(:update_params) { {pro_argument: required_keys.index_with { |_k| '12345' }} }
  let(:invalid_update_params) { {pro_argument: required_keys.index_with { |_k| ' ' }} }
  let(:create_differences) { {"#{subject.class}.count" => 1, 'Vote.count' => 1, 'Activity.count' => 2} }

  context 'with motion parent' do
    subject { argument }

    let(:created_resource_path) { parent_path }

    it_behaves_like 'requests'
  end
end

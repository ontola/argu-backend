# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:created_resource_path) { url_for(subject.parent_model) }

  context 'with motion parent' do
    subject { argument }
    it_behaves_like 'requests'
  end

  context 'with linked record parent' do
    subject { linked_record_argument }
    it_behaves_like 'requests', skip: %i[new]
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:created_resource_path) { url_for(subject.parent_model) }

  context 'with motion parent' do
    subject { argument }
    it_behaves_like 'requests', skip: %i[html_index]
  end

  context 'with linked record parent' do
    subject { linked_record_argument }
    it_behaves_like 'requests', skip: %i[new html_index]
  end
end

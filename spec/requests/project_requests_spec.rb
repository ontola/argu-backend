# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Projects', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  context 'with forum parent' do
    subject { project }
    let(:non_existing_create_path) { forum_projects_path('non_existing') }
    let(:non_existing_index_path) { forum_projects_path('non_existing') }
    let(:non_existing_new_path) { new_forum_project_path('non_existing') }

    it_behaves_like 'requests', skip: %i[json_api n3 index]
  end
end

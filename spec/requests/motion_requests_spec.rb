# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Motions', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:created_resource_path) { url_for([subject.class.last, start_motion_tour: true]) }

  context 'with question parent' do
    subject { motion }
    it_behaves_like 'requests', skip: %i[html_index], move: true
  end

  context 'with forum parent' do
    subject { forum_motion }
    let(:non_existing_create_path) { forum_motions_path('non_existing') }
    let(:non_existing_index_path) { forum_motions_path('non_existing') }
    let(:non_existing_new_path) { new_forum_motion_path('non_existing') }

    it_behaves_like 'requests', skip: %i[html_index], move: true
  end
end

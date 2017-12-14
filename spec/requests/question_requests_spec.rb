# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Questions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  context 'with forum parent' do
    subject { question }
    let(:non_existing_create_path) { forum_questions_path('non_existing') }
    let(:non_existing_index_path) { forum_questions_path('non_existing') }
    let(:non_existing_new_path) { new_forum_question_path('non_existing') }

    it_behaves_like 'requests', move: true
  end
end

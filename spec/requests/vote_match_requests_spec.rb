# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'VoteMatches', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:create_differences) { [["#{subject.class}.count", 1]] }
  let(:update_differences) { [["#{subject.class}.count", 0]] }
  let(:destroy_differences) { [["#{subject.class}.count", -1]] }

  let(:authorized_user) { subject.publisher }
  let(:required_keys) { %w[name] }

  let(:create_path) { vote_matches_path }

  context 'with user parent' do
    subject { create(:vote_match) }
    it_behaves_like 'requests', skip: %i[trash untrash html unauthorized]
  end

  context 'with page parent' do
    subject { create(:vote_match, creator: create(:page).profile) }
    it_behaves_like 'requests', skip: %i[trash untrash html unauthorized]
  end
end

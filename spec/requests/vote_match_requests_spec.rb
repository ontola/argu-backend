# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'VoteMatches', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.default_formats
    super - %i[html]
  end

  let(:create_differences) { {"#{subject.class}.count" => 1} }
  let(:update_differences) { {"#{subject.class}.count" => 0} }
  let(:destroy_differences) { {"#{subject.class}.count" => -1} }

  let(:authorized_user) { subject.publisher }
  let(:required_keys) { %w[name] }

  let(:create_path) { vote_matches_path }

  context 'with page parent' do
    subject { create(:vote_match, creator: create(:page).profile) }
    it_behaves_like 'requests',
                    skip: %i[trash untrash unauthorized new edit delete create_non_existing index_non_existing]
  end
end

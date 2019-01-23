# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Motions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:created_resource_path) { "#{subject.class.last.iri.path}?start_motion_tour=true" }

  context 'with question parent' do
    subject { motion }
    it_behaves_like 'requests', move: true
  end

  context 'with forum parent' do
    subject { forum_motion }
    it_behaves_like 'requests', move: true
  end
end

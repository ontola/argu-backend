# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Topic', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.default_formats
    super - %i[html]
  end

  context 'with forum parent' do
    subject { forum_topic }
    it_behaves_like 'requests', move: true
  end
end

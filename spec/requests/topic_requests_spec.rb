# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Topic', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  context 'with forum parent' do
    subject { forum_topic }

    it_behaves_like 'requests', move: true
  end
end

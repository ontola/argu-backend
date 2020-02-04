# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Questions', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  context 'with forum parent' do
    subject { question }

    it_behaves_like 'requests', move: true
  end
end

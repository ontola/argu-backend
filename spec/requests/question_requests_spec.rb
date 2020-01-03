# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Questions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  context 'with forum parent' do
    subject { question }

    it_behaves_like 'requests', move: true
  end
end

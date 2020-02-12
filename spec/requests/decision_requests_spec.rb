# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Decisions', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  subject { decision }

  let(:created_resource_path) { parent_path }
  let(:updated_resource_path) { parent_path }

  let(:authorized_user) { subject.forwarded_user }
  let(:create_params) do
    {
      decision: attributes_for(
        :decision,
        state: 'approved',
        content: 'Content'
      )
    }
  end
  let(:required_keys) { %w[content] }

  it_behaves_like 'requests', skip: %i[trash untrash delete destroy update_invalid]
end

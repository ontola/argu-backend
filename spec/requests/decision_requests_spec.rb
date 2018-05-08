# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Decisions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  include DecisionsHelper

  let(:created_resource_path) { parent_path }
  let(:updated_resource_path) { parent_path }

  let(:authorized_user) { subject.forwarded_user }
  let(:create_params) do
    {
      decision: attributes_for(
        :decision,
        state: 'approved',
        content: 'Content',
        happening_attributes: {happened_at: Time.current}
      )
    }
  end
  let(:required_keys) { %w[content] }

  subject { decision }
  it_behaves_like 'requests', skip: %i[trash untrash delete destroy update_invalid]
end

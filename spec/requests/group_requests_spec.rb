# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  subject { group }

  let(:update_differences) { {'Group.count' => 0} }
  let(:create_differences) { {'Group.count' => 1} }
  let(:destroy_differences) { {'Group.count' => -1} }
  let(:destroy_params) { {group: {confirmation_string: 'remove'}} }
  let(:required_keys) { %w[name] }
  let(:non_existing_index_path) { '/non_existing/groups' }

  let(:expect_get_index_unauthorized_serializer) { expect_success }
  let(:expect_get_show_unauthorized_serializer) { expect_success }

  it_behaves_like 'requests', skip: %i[trash untrash]
end

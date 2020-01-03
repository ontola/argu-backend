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

  let(:expect_get_index_guest_serializer) { expect_not_a_user }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:expect_get_form_guest_serializer) { expect_unauthorized }
  let(:expect_get_form_unauthorized_serializer) { expect_unauthorized }

  it_behaves_like 'requests', skip: %i[html trash untrash]
end

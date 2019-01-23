# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'GroupMemberships', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:create_differences) { {'group.reload.reload.group_memberships.count' => 1} }
  let(:create_guest_differences) { {} }
  let(:update_differences) { {'group.reload.group_memberships.count' => 0} }
  let(:destroy_differences) { {'group.reload.group_memberships.count' => -1} }
  let(:no_differences) { {'group.reload.group_memberships.count' => 0} }

  let(:created_resource_path) { argu.iri.path }
  let(:parent_path) { argu.iri.path }
  let(:expect_get_index_guest_serializer) { expect_not_a_user }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }

  subject { group_membership }

  it_behaves_like 'requests', skip: %i[html trash untrash create_invalid new edit update]
end

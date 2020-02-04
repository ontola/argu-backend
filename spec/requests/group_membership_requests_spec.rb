# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GroupMemberships', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:create_differences) { {'group.reload.reload.group_memberships.count' => 0} }
  let(:create_guest_differences) { {} }
  let(:update_differences) { {'group.reload.group_memberships.count' => 0} }
  let(:destroy_differences) { {'group.reload.group_memberships.count' => -1} }
  let(:no_differences) { {'group.reload.group_memberships.count' => 0} }

  let(:created_resource_path) { argu.iri.path }
  let(:expect_get_index_guest_serializer) { expect_not_a_user }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:expect_post_create_serializer) { expect_unauthorized }
  let(:expect_get_form_guest_serializer) { expect_unauthorized }
  let(:expect_get_form_unauthorized_serializer) { expect_unauthorized }

  subject { group_membership }

  it_behaves_like 'requests', skip: %i[trash untrash create_invalid new edit update]
end

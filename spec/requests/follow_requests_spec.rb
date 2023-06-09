# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  def self.unsubscribe_formats
    default_formats
  end

  subject { create(:follow, follower: staff, followable: freetown) }

  let(:create_path) { freetown.collection_iri(:follows) }
  let(:subject_parent) { subject.followable }
  let(:create_params) { {follow_type: 'reactions'} }
  let(:expect_delete_destroy_json_api) { expect(response.code).to eq('200') }
  let(:parent_path) { subject.followable.iri.path }
  let(:create_differences) { {'Follow.reactions.count' => 1} }
  let(:created_resource_path) { parent_path }
  let(:destroy_differences) { {'Follow.reactions.count' => -1, 'Follow.never.count' => 1} }
  let(:update_failed_path) { parent_path }
  let(:unsubscribe_path) { "#{subject.iri}/unsubscribe" }
  let(:non_existing_unsubscribe_path) do
    "#{iri_from_template(:follows_iri, id: non_existing_id, root_id: argu.url)}/unsubscribe"
  end
  let(:unauthorized_user) do
    freetown.grants.destroy_all
    create_forum(initial_public_grant: 'participator', parent: create(:page))
    create(:user)
  end
  let(:expect_delete_destroy_unauthorized_json_api) { expect_delete_destroy_json_api }
  let(:expect_delete_destroy_unauthorized_serializer) { expect_delete_destroy_serializer }
  let(:expect_delete_destroy_guest_json_api) { expect_delete_destroy_json_api }
  let(:expect_delete_destroy_guest_serializer) { expect_delete_destroy_serializer }

  it_behaves_like 'post create', skip: %i[invalid]
  it_behaves_like 'delete destroy'
  it_behaves_like 'get unsubscribe'
end

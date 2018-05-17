# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Follows', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  def self.unsubscribe_formats
    default_formats
  end

  let(:create_path) { follows_path(gid: freetown.edge.uuid) }
  let(:non_existing_create_path) { follows_path(gid: non_existing_id) }
  let(:create_params) { {follow_type: 'reactions'} }
  let(:expect_post_create_failed_html) { expect(response).to redirect_to(root_path) }
  let(:expect_delete_destroy_serializer) { expect(response.code).to eq('204') }
  let(:parent_path) { subject.followable.owner.iri_path }
  let(:create_differences) { [['Follow.reactions.count', 1]] }
  let(:created_resource_path) { parent_path }
  let(:destroy_differences) { [['Follow.reactions.count', -1], ['Follow.never.count', 1]] }
  let(:update_failed_path) { parent_path }
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(parent_path)
  end
  let(:unsubscribe_path) { unsubscribe_follow_path(subject) }
  let(:non_existing_unsubscribe_path) { unsubscribe_follow_path(non_existing_id) }

  subject { create(:follow, follower: staff, followable: freetown.edge) }

  it_behaves_like 'post create', skip: %i[invalid]
  it_behaves_like 'delete destroy'
  it_behaves_like 'get unsubscribe'
end

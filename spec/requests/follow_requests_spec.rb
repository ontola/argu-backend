# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Follows', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  def self.unsubscribe_formats
    default_formats
  end

  let(:create_path) { "#{collection_iri(argu, :follows)}?gid=#{freetown.uuid}" }
  let(:non_existing_create_path) { "#{collection_iri(argu, :follows, root: argu)}?gid=#{non_existing_id}" }
  let(:create_params) { {follow_type: 'reactions'} }
  let(:expect_post_create_failed_html) { expect(response).to redirect_to(root_path) }
  let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
  let(:parent_path) { subject.followable.iri.path }
  let(:create_differences) { {'Follow.reactions.count' => 1} }
  let(:created_resource_path) { parent_path }
  let(:destroy_differences) { {'Follow.reactions.count' => -1, 'Follow.never.count' => 1} }
  let(:update_failed_path) { parent_path }
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(parent_path)
  end
  let(:unsubscribe_path) do
    iri_from_template(:follows_unsubscribe_iri, id: subject, root_id: argu.url)
  end
  let(:non_existing_unsubscribe_path) do
    iri_from_template(:follows_unsubscribe_iri, id: non_existing_id, root_id: argu.url)
  end
  let(:unauthorized_user) do
    freetown.grants.destroy_all
    create_forum(public_grant: 'participator', parent: create(:page))
    create(:user)
  end

  subject { create(:follow, follower: staff, followable: freetown) }

  it_behaves_like 'post create', skip: %i[invalid]
  it_behaves_like 'delete destroy'
  it_behaves_like 'get unsubscribe'
end

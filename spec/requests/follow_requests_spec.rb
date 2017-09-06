# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Follows', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:create_path) { follows_path(gid: freetown.edge.id) }
  let(:non_existing_create_path) { follows_path(gid: -1) }
  let(:create_params) { {follow_type: 'reactions'} }
  let(:expect_post_create_failed_html) { expect(response).to redirect_to(root_path) }
  let(:parent_path) { forum_path(subject.followable.owner) }
  let(:create_differences) { [['Follow.reactions.count', 1]] }
  let(:created_resource_path) { parent_path }
  let(:destroy_differences) { [['Follow.reactions.count', -1], ['Follow.never.count', 1]] }
  let(:update_failed_path) { parent_path }
  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(parent_path)
  end
  let(:unsubscribe_path) { unsubscribe_follow_path(subject) }
  let(:non_existing_unsubscribe_path) { unsubscribe_follow_path(-1) }

  subject { create(:follow, follower: staff, followable: freetown.edge) }

  %i[html json_api n3].each do |format|
    context "as #{format}" do
      let(:request_format) { format }
      it_behaves_like 'post create', skip: %i[invalid]
      it_behaves_like 'delete destroy'
      it_behaves_like 'get unsubscribe'
    end
  end
end

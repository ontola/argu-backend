# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Discussions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:non_existing_new_path) { new_forum_discussion_path(-1) }

  context 'for discoverable forum' do
    let(:new_path) { new_forum_discussion_path(freetown) }
    let(:expect_redirect_to_login) { expect_get_new }
    it_behaves_like 'get new'
  end

  context 'for hidden forum' do
    let(:new_path) { new_forum_discussion_path(holland) }
    let(:expect_unauthorized) { expect_not_found }
    let(:expect_redirect_to_login) { expect_not_found }
    it_behaves_like 'get new'
  end
end

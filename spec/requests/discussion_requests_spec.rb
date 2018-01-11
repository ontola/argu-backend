# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Discussions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:non_existing_new_path) { new_forum_discussion_path(-1) }
  let(:new_path) { new_forum_discussion_path(subject.parent_model) }
  def self.index_formats
    super - %i[html]
  end

  context 'for discoverable forum' do
    let(:subject) { Discussion.new(forum: freetown) }
    let(:expect_redirect_to_login) { expect_get_new }
    it_behaves_like 'get new'
    it_behaves_like 'get index'
  end

  context 'for hidden forum' do
    let(:subject) { Discussion.new(forum: holland) }
    let(:expect_unauthorized) { expect_not_found }
    let(:expect_redirect_to_login) { expect_not_found }
    let(:expect_get_index_guest_html) { expect_not_found }
    let(:expect_get_index_guest_serializer) { expect_not_found }
    it_behaves_like 'get new'
    it_behaves_like 'get index'
  end
end

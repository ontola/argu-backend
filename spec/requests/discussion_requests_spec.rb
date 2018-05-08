# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Discussions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  context 'for page' do
    let(:subject) { Discussion.new(page: argu) }
    it_behaves_like 'get index', skip: %i[unauthorized]
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

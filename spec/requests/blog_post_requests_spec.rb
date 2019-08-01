# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'BlogPosts', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end

  let(:expect_get_new_guest_serializer) { expect_unauthorized }

  context 'with motion parent' do
    subject { motion_blog_post }
    it_behaves_like 'requests'
  end

  context 'with question parent' do
    subject { blog_post }
    it_behaves_like 'requests'
  end
end

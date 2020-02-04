# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BlogPosts', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  context 'with motion parent' do
    subject { motion_blog_post }
    it_behaves_like 'requests'
  end

  context 'with question parent' do
    subject { blog_post }
    it_behaves_like 'requests'
  end
end

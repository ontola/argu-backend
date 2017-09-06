# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'BlogPosts', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:create_params) do
    {blog_post: attributes_for(:blog_post).merge(happening_attributes: {happened_at: Time.current})}
  end
  let(:created_resource_path) do
    url_for([subject.parent_model, happening_id: subject.class.last.happening.id, only_path: true])
  end

  context 'with motion parent' do
    subject { motion_blog_post }
    it_behaves_like 'requests', skip: %i[html_index]
  end

  context 'with question parent' do
    subject { blog_post }
    it_behaves_like 'requests', skip: %i[html_index]
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:created_resource_path) { parent_path }
  let(:create_failed_path) do
    "#{new_iri(index_path).path}?#{{comment: {body: create_params[:comment][:body]}, confirm: true}.to_query}"
  end
  let(:destroy_differences) { {'Comment.where(description: "").count' => 1, 'Activity.count' => 1} }
  let(:required_keys) { %w[body] }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_trash) { staff }
  let(:create_differences) { {"#{subject.class}.count" => 1, 'Activity.count' => 1} }

  context 'with comment parent' do
    subject { nested_comment }

    let(:index_path) { subject.parent_comment.collection_iri(:comments).path }

    it_behaves_like 'requests'
  end

  context 'with argument parent' do
    subject { comment }

    it_behaves_like 'requests'
  end

  context 'with motion parent' do
    subject { motion_comment }

    it_behaves_like 'requests'
  end

  context 'with blog_post parent' do
    subject { blog_post_comment }

    it_behaves_like 'requests'
  end
end

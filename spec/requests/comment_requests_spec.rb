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

    let(:index_path) { collection_iri(subject.parent_comment, table_sym).path }

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

  context 'with linked_record parent' do
    subject { linked_record_comment }

    let(:parent_path) {}

    it_behaves_like 'requests'
  end

  context 'with non-persisted linked_record parent' do
    subject { build(:comment, parent: non_persisted_linked_record) }

    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }

    let(:parent_path) {}

    it_behaves_like 'post create'
    it_behaves_like 'get index'
  end
end

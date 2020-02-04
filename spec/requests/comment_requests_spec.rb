# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:redirect_url) { "#{subject_parent.iri.path}#comments_#{subject.id}" }
  let(:create_failed_path) do
    "#{new_iri(index_path).path}?#{{comment: {body: create_params[:comment][:body]}, confirm: true}.to_query}"
  end
  let(:created_resource_path) { "#{Comment.last.parent.iri.path}#comments_#{Comment.last.id}" }
  let(:destroy_differences) { {'Comment.where(description: "").count' => 1, 'Activity.count' => 1} }
  let(:required_keys) { %w[body] }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_trash) { staff }
  let(:update_failed_path) { redirect_url }
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
    let(:redirect_url) { index_path }
    let(:created_resource_path) { redirect_url }
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
    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
    subject { build(:comment, parent: non_persisted_linked_record) }
    let(:parent_path) {}
    it_behaves_like 'post create'
    it_behaves_like 'get index'
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Comments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:redirect_url) { subject.parent.iri_path(fragment: "comments_#{subject.id}") }
  let(:expect_get_show_html) do
    expect(response).to redirect_to(redirect_url)
    follow_redirect!
    expect(response.status).to eq(200)
  end
  let(:expect_post_create_failed_html) do
    expect(response).to(
      redirect_to("#{subject.parent.iri_path}?#{{comment: {body: '1', parent_id: nil}}.to_param}")
    )
  end
  let(:expect_delete_trash_html) { expect(response).to redirect_to(redirect_url) }
  let(:expect_put_untrash_html) { expect(response).to redirect_to(redirect_url) }
  let(:create_failed_path) do
    "#{new_iri_path(index_path)}?#{{comment: {body: create_params[:comment][:body]}, confirm: true}.to_query}"
  end
  let(:created_resource_path) { Comment.last.parent.iri_path(fragment: "comments_#{Comment.last.id}") }
  let(:destroy_differences) { [['Comment.where(description: "").count', 1], ['Activity.count', 1]] }
  let(:required_keys) { %w[body] }
  let(:authorized_user_update) { subject.publisher }
  let(:authorized_user_trash) { staff }
  let(:update_failed_path) { redirect_url }

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
    it_behaves_like 'requests', skip: %i[html]
  end

  context 'with non-persisted linked_record parent' do
    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
    subject { build(:comment, parent: non_persisted_linked_record) }
    let(:parent_path) {}
    it_behaves_like 'post create', skip: %i[html]
    it_behaves_like 'get index', skip: %i[html]
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Comments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:redirect_url) { url_for([subject.parent_model, anchor: "comments_#{subject.id}", only_path: true]) }
  let(:expect_get_show_html) do
    expect(response).to redirect_to(redirect_url)
    follow_redirect!
    expect(response.status).to eq(200)
  end
  let(:expect_post_create_failed_html) do
    redirect_to(url_for([subject.parent_model, comment: {body: 'comment', parent: nil}]))
  end
  let(:expect_delete_trash_html) { expect(response).to redirect_to(redirect_url) }
  let(:expect_put_untrash_html) { expect(response).to redirect_to(redirect_url) }
  let(:create_failed_path) do
    url_for(
      [
        :new,
        subject.parent_model,
        subject.class.name.underscore.to_sym,
        comment: {body: create_params[:comment][:body]},
        confirm: true,
        only_path: true
      ]
    )
  end
  let(:created_resource_path) { url_for([Comment.last.parent_model, anchor: "comments_#{Comment.last.id}"]) }
  let(:destroy_differences) { [['Comment.where(body: "").count', 1], ['Activity.loggings.count', 1]] }
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
    let(:redirect_url) { motion_comments_path(subject.parent_model) }
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
    let(:index_path) do
      linked_record_comments_path(organization: argu.url, forum: freetown.url, linked_record_id: linked_record.deku_id)
    end
    let(:non_existing_index_path) do
      linked_record_comments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
    end
    it_behaves_like 'requests', skip: %i[html]
  end

  context 'with non-persisted linked_record parent' do
    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
    subject { build(:comment, edge: Edge.new(parent: non_persisted_linked_record.edge)) }
    let(:parent_path) {}
    let(:index_path) do
      linked_record_comments_path(organization: argu.url, forum: freetown.url, linked_record_id: SecureRandom.uuid)
    end
    let(:non_existing_index_path) do
      linked_record_comments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
    end
    it_behaves_like 'post create', skip: %i[html]
    it_behaves_like 'get index', skip: %i[html]
  end
end

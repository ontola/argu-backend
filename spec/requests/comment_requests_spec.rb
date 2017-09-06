# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Comments', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:expect_get_show_html) do
    expect(response).to redirect_to(url_for([subject.parent_model, anchor: "comments_#{subject.id}"]))
    follow_redirect!
    expect(response.status).to eq(200)
  end
  let(:expect_post_create_failed_html) do
    redirect_to(url_for([subject.parent_model, comment: {body: 'comment', parent: nil}]))
  end
  let(:expect_delete_trash_html) do
    expect(response).to redirect_to(url_for([subject.parent_model, anchor: "comments_#{subject.id}", only_path: true]))
  end
  let(:expect_put_untrash_html) { expect_delete_trash_html }
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
  let(:update_failed_path) { url_for([subject.parent_model, anchor: "comments_#{subject.id}", only_path: true]) }

  context 'with motion parent' do
    subject { comment }
    it_behaves_like 'requests'
  end

  context 'with blog_post parent' do
    subject { blog_post_comment }
    it_behaves_like 'requests'
  end
end

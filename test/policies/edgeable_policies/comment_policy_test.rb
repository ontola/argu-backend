# frozen_string_literal: true

require 'test_helper'
class CommentPolicyTest < Argu::TestHelpers::PolicyTest
  include Argu::TestHelpers::DefaultPolicyTests
  subject { comment }
  let(:trashed_subject) { trashed_comment }
  let(:expired_subject) { expired_comment }
  let(:unpublished_subject) { unpublished_comment }
  let(:direct_child) { nested_comment }
  let(:expired_blog_post_comment) { create(:comment, parent: blog_post, publisher: creator) }

  generate_edgeable_tests

  test 'create comment for expired blog_post' do
    test_policy(expired_blog_post_comment, :create, create_results)
  end

  private

  alias destroy_with_children_results destroy_results
  alias feed_results nobody_results

  def update_results
    nobody_results.merge(creator: true)
  end
end

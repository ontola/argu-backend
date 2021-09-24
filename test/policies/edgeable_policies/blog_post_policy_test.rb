# frozen_string_literal: true

require 'test_helper'
class BlogPostPolicyTest < Argu::TestHelpers::PolicyTest
  subject { blog_post }
  let(:trashed_subject) { trashed_blog_post }
  let(:expired_subject) { expired_blog_post }
  let(:unpublished_subject) { unpublished_blog_post }
  let(:direct_child) { blog_post_comment }

  test 'edgeable policies blog post' do
    test_edgeable_policies
  end

  alias create_results moderator_plus_results
  alias create_expired_results moderator_plus_results
  alias feed_results nobody_results
end

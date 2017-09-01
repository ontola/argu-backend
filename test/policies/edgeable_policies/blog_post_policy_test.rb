# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class BlogPostPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { blog_post }
  let(:trashed_subject) { trashed_blog_post }
  let(:expired_subject) { expired_blog_post }
  let(:direct_child) { blog_post_comment }

  generate_edgeable_tests

  alias create_results manager_plus_results
  alias create_expired_results manager_plus_results
  alias create_results manager_plus_results
  alias feed_results nobody_results
end

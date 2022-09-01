# frozen_string_literal: true

require 'test_helper'
class PagePolicyTest < Argu::TestHelpers::PolicyTest
  subject { page }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:unpublished_subject) { nil }
  let(:creator) { page.publisher }

  test 'edgeable policies page' do
    test_edgeable_policies
  end

  def feed_results
    super.except(:non_member)
  end

  def follow_results
    super.except(:non_member)
  end

  def show_results
    super.except(:non_member)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def create_results
    everybody_results.merge(creator: false)
  end

  def trash_results
    staff_only_results
  end
end

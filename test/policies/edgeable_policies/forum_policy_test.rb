# frozen_string_literal: true

require 'test_helper'
class ForumPolicyTest < Argu::TestHelpers::PolicyTest
  subject { freetown }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:unpublished_subject) { nil }
  let(:direct_child) { question }

  test 'edgeable policies forum' do
    test_edgeable_policies
  end

  private

  def create_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def trash_results
    nobody_results
  end

  def invite_results
    nobody_results.merge(administrator: true, staff: true)
  end
end

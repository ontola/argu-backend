# frozen_string_literal: true

require 'test_helper'
class PagePolicyTest < Argu::TestHelpers::PolicyTest
  include Argu::TestHelpers::DefaultPolicyTests
  subject { page }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:unpublished_subject) { nil }
  let(:creator) { page.publisher }

  generate_edgeable_tests

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def create_results
    everybody_results.merge(guest: false, creator: false)
  end

  def trash_results
    nobody_results
  end
end

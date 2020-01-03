# frozen_string_literal: true

require 'test_helper'
class LinkedRecordPolicyTest < Argu::TestHelpers::PolicyTest
  include Argu::TestHelpers::DefaultPolicyTests
  subject { linked_record }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:unpublished_subject) { nil }
  let(:direct_child) { linked_record_argument }

  generate_edgeable_tests

  alias create_results nobody_results
  alias update_results nobody_results
  alias destroy_results nobody_results
  alias destroy_with_children_results nobody_results
  alias trash_results nobody_results
  alias untrash_results nobody_results
end

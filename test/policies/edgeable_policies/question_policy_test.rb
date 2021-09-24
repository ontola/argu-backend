# frozen_string_literal: true

require 'test_helper'
class QuestionPolicyTest < Argu::TestHelpers::PolicyTest
  subject { question }
  let(:trashed_subject) { trashed_question }
  let(:expired_subject) { expired_question }
  let(:unpublished_subject) { unpublished_question }
  let(:direct_child) { motion }

  test 'edgeable policies question' do
    test_edgeable_policies
  end

  private

  alias move_results moderator_plus_results
  alias convert_results staff_only_results

  def create_results
    everybody_results.merge(spectator: false, participator: false, non_member: false)
  end

  def invite_results
    nobody_results.merge(administrator: true, staff: true)
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class QuestionAnswerPolicyTest < PolicyTest
  subject { QuestionAnswer.new(question: question, motion: motion) }

  test 'create question_answer' do
    test_policy(subject, :create, moderator_plus_results)
  end
end

require 'test_helper'

class QuestionAnswerTest < ActiveSupport::TestCase

  def question_answer
    @question_answer ||= question_answers(:one)
  end

  def test_valid
    assert question_answer.valid?, question_answer.errors.to_a.join(',').to_s
  end

end

require "test_helper"

class QuestionTest < ActiveSupport::TestCase

  def question
    @question ||= motions(:one)
  end

  def test_valid
    assert question.valid?, question.errors.to_a.join(',').to_s
  end

end

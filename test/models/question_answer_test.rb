require 'test_helper'

class QuestionAnswerTest < ActiveSupport::TestCase
  let(:question) { create(:question) }
  let(:motion) { create(:motion) }
  subject do
    QuestionAnswer.new(question: question,
                       motion: motion)
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

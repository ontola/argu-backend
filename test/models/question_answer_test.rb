require 'test_helper'

class QuestionAnswerTest < ActiveSupport::TestCase
  let(:freetown) { create(:forum) }
  let(:question) { create(:question, forum: freetown) }
  let(:motion) { create(:motion, forum: freetown) }
  subject do
    QuestionAnswer.new(question: question,
                       motion: motion)
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

require 'test_helper'

class QuestionAnswerTest < ActiveSupport::TestCase
  let(:question) { FactoryGirl.create(:question) }
  let(:motion) { FactoryGirl.create(:motion) }
  subject do
    QuestionAnswer.new(question: question,
                       motion: motion)
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

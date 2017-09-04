# frozen_string_literal: true

require 'test_helper'

class QuestionAnswerTest < ActiveSupport::TestCase
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  subject do
    QuestionAnswer.new(question: question,
                       motion: motion)
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

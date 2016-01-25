require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  subject { FactoryGirl.create(:question) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

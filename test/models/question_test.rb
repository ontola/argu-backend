require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  let(:freetown) { create(:forum) }
  subject { create(:question, forum: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

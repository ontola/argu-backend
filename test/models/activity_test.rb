require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  let(:freetown) { create(:forum) }
  subject { create(:activity, forum: freetown) }

  def test_valid
    assert subject.valid?
  end
end

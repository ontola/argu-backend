require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  define_common_objects :freetown
  subject { create(:activity, forum: freetown) }

  def test_valid
    assert subject.valid?
  end
end

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  let(:freetown) { FactoryGirl.create(:forum) }
  subject { FactoryGirl.create(:activity,
                               forum: freetown) }

  def test_valid
    assert subject.valid?
  end

end

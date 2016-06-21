require 'test_helper'

class PlacementTest < ActiveSupport::TestCase
  subject do
    create(:placement)
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'creating multiple home_placements should raise exception' do
    u = create(:user)
    assert_raises(ActiveRecord::RecordNotUnique) do
      create(:home_placement, placeable: u)
      create(:home_placement, placeable: u)
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class PlacementTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  subject { create(:placement, edge: motion, root: argu, lat: 1.0, lon: 1.0) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end

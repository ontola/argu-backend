# frozen_string_literal: true

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:activity, forum: freetown, trackable: create(:motion, parent: freetown.edge)) }

  def test_valid
    assert subject.valid?
  end
end

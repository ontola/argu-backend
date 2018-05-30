# frozen_string_literal: true

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  define_freetown
  subject do
    create(
      :activity,
      forum: freetown,
      trackable: create(:motion, parent: freetown),
      trackable_type: 'Motion',
      recipient: freetown,
      recipient_type: 'Forum'
    )
  end

  def test_valid
    assert subject.valid?
  end
end

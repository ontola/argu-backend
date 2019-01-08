# frozen_string_literal: true

require 'test_helper'

class NewsBoyTest < ActiveSupport::TestCase
  define_freetown
  let!(:published_with_future_ends_at) do
    create(:announcement, published_at: 1.day.ago, ends_at: 15.minutes.from_now)
  end
  let!(:published_with_passed_ends_at) do
    create(:announcement, published_at: 1.day.ago, ends_at: 15.minutes.ago)
  end
  let!(:published_without_ends_at) do
    create(:announcement, published_at: 1.day.ago)
  end
  let!(:scheduled_with_future_ends_at) do
    create(:announcement, published_at: 1.day.from_now, ends_at: 15.minutes.from_now)
  end
  let!(:scheduled_without_ends_at) do
    create(:announcement, published_at: 1.day.from_now)
  end
  let!(:unpublished_with_future_ends_at) do
    create(:announcement, ends_at: 15.minutes.from_now)
  end
  let!(:unpublished_with_passed_ends_at) do
    create(:announcement, ends_at: 15.minutes.ago)
  end
  let!(:unpublished_without_ends_at) { create(:announcement) }

  test 'find correct published counts' do
    assert_equal 2, Announcement.published.count,
                 'NewsBoy.published query is incorrect'
  end

  test 'find correct unpublished counts' do
    assert_equal 6, Announcement.unpublished.count,
                 'NewsBoy.unpublished query is incorrect'
  end

  test 'find correct ended counts' do
    assert_equal 1, Announcement.ended.count,
                 'NewsBoy.ended query is incorrect'
  end
end

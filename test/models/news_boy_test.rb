require 'test_helper'

class NewsBoyTest < ActiveSupport::TestCase
  define_freetown
  let!(:published_with_future_ends_at) do
    create(:banner, published_at: 1.day.ago, ends_at: 15.minutes.from_now, forum: freetown)
  end
  let!(:published_with_passed_ends_at) do
    create(:banner, published_at: 1.day.ago, ends_at: 15.minutes.ago, forum: freetown)
  end
  let!(:published_without_ends_at) do
    create(:banner, published_at: 1.day.ago, forum: freetown)
  end
  let!(:scheduled_with_future_ends_at) do
    create(:banner, published_at: 1.day.from_now, ends_at: 15.minutes.from_now, forum: freetown)
  end
  let!(:scheduled_without_ends_at) do
    create(:banner, published_at: 1.day.from_now, forum: freetown)
  end
  let!(:unpublished_with_future_ends_at) do
    create(:banner, ends_at: 15.minutes.from_now, forum: freetown)
  end
  let!(:unpublished_with_passed_ends_at) do
    create(:banner, ends_at: 15.minutes.ago, forum: freetown)
  end
  let!(:unpublished_without_ends_at) do
    create(:banner, forum: freetown)
  end

  test 'find correct published counts' do
    assert_equal 2, Banner.published.count,
                 'NewsBoy.published query is incorrect'
  end

  test 'find correct unpublished counts' do
    assert_equal 6, Banner.unpublished.count,
                 'NewsBoy.unpublished query is incorrect'
  end

  test 'find correct ended counts' do
    assert_equal 1, Banner.ended.count,
                 'NewsBoy.ended query is incorrect'
  end
end

require 'test_helper'

class NewsBoyTest < ActiveSupport::TestCase
  let!(:published_with_future_ends_at) { create(:banner, :published, :not_yet_ended) }
  let!(:published_with_passed_ends_at) { create(:banner, :published, :ended) }
  let!(:published_without_ends_at) { create(:banner, :published, :without_ending) }
  let!(:scheduled_with_future_ends_at) { create(:banner, :scheduled, :not_yet_ended) }
  let!(:scheduled_without_ends_at) { create(:banner, :scheduled, :without_ending) }
  let!(:unpublished_with_future_ends_at) { create(:banner, :unpublished, :not_yet_ended) }
  let!(:unpublished_with_passed_ends_at) { create(:banner, :unpublished, :ended) }
  let!(:unpublished_without_ends_at) { create(:banner, :unpublished, :without_ending) }

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

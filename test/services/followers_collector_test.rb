require 'test_helper'

class FollowersCollectorTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let!(:follow) { create(:follow, followable: project.edge) }
  let!(:news_follow) { create(:news_follow, followable: project.edge) }

  test 'should collect 0 for unfollowed project' do
    Follow.destroy_all
    assert_equal 0, FollowersCollector.new(project, :reactions).call.count
  end

  test 'should collect reaction followers for project' do
    assert_equal 2, FollowersCollector.new(project, :reactions).call.count
  end

  test 'should collect news followers for project' do
    assert_equal 3, FollowersCollector.new(project, :news).call.count
  end
end

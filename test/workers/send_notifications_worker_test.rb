require 'test_helper'

class SendNotificationsWorkerTest < ActiveSupport::TestCase
  let!(:activity) do
    FactoryGirl.create(:activity,
                       :t_argument,
                       trackable: argument,
                       forum: argument.forum)
  end

  let!(:argument) { FactoryGirl.create(:argument) }

  let!(:follow) do
    FactoryGirl.create(:follow,
                       :t_argument,
                       followable: argument,
                       follower: follower)
  end

  let!(:follower) { FactoryGirl.create :user }

  let!(:notification) do
    FactoryGirl.create(:notification,
                       activity: activity,
                       user: follower)
  end

  test 'collect_notifications should return notifications' do
    snw = SendNotificationsWorker.new

    assert_equal 1, snw.collect_notifications(follow.follower).length
  end
end

# frozen_string_literal: true
require 'test_helper'

class DirectNotificationsSchedulerWorkerTest < ActiveSupport::TestCase
  test 'should be scheduled weekly' do
    assert_equal 'Minutely', DirectNotificationsSchedulerWorker.schedule.to_s
    assert_equal 3, DirectNotificationsSchedulerWorker::EMAIL_FREQUENCY
  end
end

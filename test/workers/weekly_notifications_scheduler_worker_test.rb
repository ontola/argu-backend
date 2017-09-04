# frozen_string_literal: true

require 'test_helper'

class WeeklyNotificationsSchedulerWorkerTest < ActiveSupport::TestCase
  test 'should be scheduled weekly' do
    assert_equal 'Weekly', WeeklyNotificationsSchedulerWorker.schedule.to_s
  end
end

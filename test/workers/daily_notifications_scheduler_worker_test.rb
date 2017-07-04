# frozen_string_literal: true
require 'test_helper'

class DailyNotificationsSchedulerWorkerTest < ActiveSupport::TestCase
  test 'should be scheduled daily' do
    assert_equal 'Daily', DailyNotificationsSchedulerWorker.schedule.to_s
  end
end

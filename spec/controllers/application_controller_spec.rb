require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  let!(:holland) { FactoryGirl.create(:populated_forum,
                                      name: 'holland') }
  let(:motion) { FactoryGirl.create(:motion,
                                    forum: holland) }
  let(:user) { create_member(holland) }

  describe '#create_activity' do
    it 'creates two activities' do
      assert_equal 0, Argu::NotificationWorker.jobs.size
      assert_equal 0, Argu::EmailNotificationWorker.jobs.size
      controller.create_activity(motion,
                                 action: :create,
                                 recipient: holland,
                                 owner: user.profile,
                                 forum: holland)
      assert_equal 1, Argu::NotificationWorker.jobs.size
      assert_equal 1, Argu::EmailNotificationWorker.jobs.size
    end
  end

end

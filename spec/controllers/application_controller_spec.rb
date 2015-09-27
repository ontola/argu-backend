require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  let!(:holland) { FactoryGirl.create(:populated_forum,
                                      name: 'holland') }
  let(:motion) { FactoryGirl.create(:motion,
                                    forum: holland) }
  let(:user) { create_member(holland) }

  describe '#create_activity' do
    it 'creates an activity' do
      expect do
        controller.create_activity(motion,
                                   action: :create,
                                   recipient: holland,
                                   owner: user.profile,
                                   forum: holland)
      end.to change { Activity.count }
    end
  end

end

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let!(:holland) { create(:populated_forum, name: 'holland') }
  define_common_objects :user,
                        member: {forum: :holland},
                        motion: {forum: :holland}

  describe '#create_activity' do
    it 'creates an activity' do
      expect do
        controller.create_activity(motion,
                                   action: :create,
                                   recipient: holland,
                                   owner: member.profile,
                                   forum: holland)
      end.to change { Activity.count }
    end
  end
end

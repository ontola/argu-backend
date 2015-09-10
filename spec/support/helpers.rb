

module Helpers
  def make_manager(forum, user = nil)
    user ||= FactoryGirl.create(:user)
    FactoryGirl.create(:managership, forum: forum, profile: user.profile)
    user
  end

  def make_member(forum, user = nil)
    user ||= FactoryGirl.create(:user)
    FactoryGirl.create(:membership, forum: forum, profile: user.profile)
    user
  end
end

RSpec.configure do |config|
  config.include Helpers
end

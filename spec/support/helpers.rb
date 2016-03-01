

module Helpers
  def create_manager(forum, user = nil)
    user ||= create(:user)
    create(:managership,
           forum: forum,
           profile: user.profile)
    user
  end

  def create_member(forum, user = nil)
    user ||= create(:user)
    create(:membership,
           forum: forum,
           profile: user.profile)
    user
  end
end

RSpec.configure do |config|
  config.include Helpers
end

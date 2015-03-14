class UserContext
  attr_reader :user, :actor, :session

  def initialize(user, profile, session)
    @user = user
    @actor = profile
    @session = session
  end
end
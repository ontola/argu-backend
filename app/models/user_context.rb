# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :session

  def initialize(user, profile, session)
    @user = user
    @actor = profile
    @session = session
  end
end
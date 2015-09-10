# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :session, :forum, :opts

  def initialize(user, profile, session, forum, opts = {})
    @user = user
    @actor = profile
    @session = session
    @forum = forum
    @opts = opts
  end
end

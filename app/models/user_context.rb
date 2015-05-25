# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :session, :context_model

  def initialize(user, profile, session, context_model= nil)
    @user = user
    @actor = profile
    @session = session
    @context_model = context_model
  end
end

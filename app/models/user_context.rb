# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :opts

  def initialize(user, profile, doorkeeper_scopes, opts = {})
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @opts = opts
  end
end

# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :a_tokens, :opts

  def initialize(user, profile, doorkeeper_scopes, a_tokens, opts = {})
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @a_tokens = a_tokens
    @opts = opts
  end
end

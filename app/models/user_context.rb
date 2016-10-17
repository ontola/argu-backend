# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :a_tokens, :opts

  def initialize(user, profile, a_tokens, opts = {})
    @user = user
    @actor = profile
    @a_tokens = a_tokens
    @opts = opts
  end
end

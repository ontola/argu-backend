# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :a_tokens, :context_model, :opts
  alias forum context_model

  def initialize(user, profile, a_tokens, context_model = nil, opts = {})
    @user = user
    @actor = profile
    @a_tokens = a_tokens
    @context_model = context_model
    @opts = opts
  end
end

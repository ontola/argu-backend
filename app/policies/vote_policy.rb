# frozen_string_literal: true
class VotePolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      if staff?
        scope
      else
        scope
        profiles = Profile.arel_table
        scope.joins(:voter).where(profiles[:are_votes_public].eq(true))
      end
    end
  end

  module Roles
    def is_creator?
      creator if user && actor == record.voter
    end
  end
  include Roles

  def create?
    return if record.edge.parent.owner.closed?
    rule is_member?, is_manager?, is_owner?, super
  end

  def update?
    rule is_creator?, super
  end

  def destroy?
    rule is_creator?, super
  end
end

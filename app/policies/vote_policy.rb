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

    def is_group_member?
      group_grant if is_member? && user&.profile&.group_ids.include?(record.parent_model.group.id)
    end
  end
  include Roles

  def show?
    if record.voter.are_votes_public
      Pundit.policy(context, record.parent_model).show?
    else
      rule staff?
    end
  end

  def create?
    return create_expired? if has_expired_ancestors?
    if record.parent_model.is_a?(VoteEvent)
      rule is_group_member?
    else
      rule is_member?, is_manager?, is_owner?, super
    end
  end

  def update?
    rule is_creator?, super
  end

  def destroy?
    rule is_creator?, super
  end

  def has_expired_ancestors?
    record.parent_model.try(:closed?) || super
  end
end

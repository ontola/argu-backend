# frozen_string_literal: true
class VotePolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

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
    rule is_member?, is_manager?, is_owner?, super
  end

  def update?
    rule is_creator?, super
  end

  def new?
    rule is_open?, create?, super
  end

  def destroy?
    rule is_creator?, super
  end
end

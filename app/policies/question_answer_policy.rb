# frozen_string_literal: true
class QuestionAnswerPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope
    end
  end

  def edge
    record.question.edge
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(id motion_id question_id)
    attributes
  end

  def create?
    rule is_manager?, is_owner?, super
  end

  def edit?
    rule update?
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at) ||
      is_manager? ||
      is_owner? ||
      super
  end

  def new?
    rule is_manager?, is_owner?, super
  end

  def update?
    rule is_manager?, is_owner?, super
  end

  def shortname?
    false
  end
end

# frozen_string_literal: true
class DocumentPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      scope
    end
  end

  # #####CRUD######
  def show?
    true
  end

  def create?
    staff?
  end

  def update?
    staff?
  end
end

class DocumentPolicy < ApplicationPolicy
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
      scope
    end

  end

  ######CRUD######
  def show?
    true
  end

  def new?
    create?
  end

  def create?
    staff?
  end

  def edit?
    update?
  end

  def update?
    staff?
  end

end

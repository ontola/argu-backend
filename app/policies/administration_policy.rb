class AdministrationPolicy < Struct.new(:user, :administration)
  class Scope
    attr_reader :context, :user, :scope, :session

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

  def show?
    user.has_role? :staff
  end

  def list?
    user.has_role? :staff
  end
end

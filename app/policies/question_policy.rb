class QuestionPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    def permitted_attributes
      attributes = super
      attributes << [:id, :title, :content, :tag_list, :forum_id] if edit?
    end

  end

  def edit?
    is_member? && is_creator? || super
  end

  def index?
    is_member? || super
  end

  def show?
    is_member? || super
  end

  private

  def is_member?
    user.profile.member_of? record.forum
  end
end

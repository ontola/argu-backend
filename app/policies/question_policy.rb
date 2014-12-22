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

    def is_member?
      user.profile.member_of? record.forum
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:id, :title, :content, :tag_list, :forum_id] if create?
    attributes
  end

  def new?
    create?
  end

  def create?
    is_member? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  def edit?
     update?
  end

  def index?
    is_member? || super
  end

  def show?
    is_member? || super
  end

  private

  def is_member?
    user.profile.member_of? (record.forum || record.forum_id)
  end
end

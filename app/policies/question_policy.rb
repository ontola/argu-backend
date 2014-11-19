class QuestionPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if current_scope.present?
        scope.where(forum_id: user._current_scope.id)
      else
        scope.where(forum_id: nil)
      end
    end

  end

  def index?
    (user._current_scope.present? && Forum.public_forms[user._current_scope.public_form] == Forum.public_forms[:f_public]) || (user && user.profile.memberships.where(forum: record).present?) || super
  end
end

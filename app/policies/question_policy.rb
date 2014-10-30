class QuestionPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user._current_scope.present?
        scope.where(organisation_id: user._current_scope.id)
      else
        scope.where(organisation_id: nil)
      end
    end

  end

  def index?
    (user._current_scope.present? && Organisation.public_forms[user._current_scope.public_form] == Organisation.public_forms[:f_public]) || (user && user.profile.memberships.where(organisation: record).present?) || super
  end
end

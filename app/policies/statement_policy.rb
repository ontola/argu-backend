class StatementPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user._current_scope.present?
        puts "===============SCOPED================"
        scope.where(organisation_id: user._current_scope.id)
      else
        puts "===============NORMAL================"
        scope.where(organisation_id: nil)
      end
    end

  end
end

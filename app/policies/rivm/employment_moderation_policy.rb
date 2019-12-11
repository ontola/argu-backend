# frozen_string_literal: true

class EmploymentModerationPolicy < EmploymentPolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      administrator = staff? ||
        grant_tree.grant_sets(grant_tree.tree_root, group_ids: user.profile.group_ids).include?('administrator')

      administrator ? scope.where(validated: [nil, false]) : scope.none
    end
  end

  def show?
    staff? || administrator?
  end

  def update?
    staff? || administrator?
  end
end

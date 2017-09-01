# frozen_string_literal: true

class EdgeablePolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_member?, is_manager?, is_super_admin?, super
  end
end

# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  def edge
    record.forum.edge
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(shortname owner_id owner_type) if is_manager_up?
    attributes
  end

  def create?
    r, m = rule is_super_admin?, super
    return r, m if r && !record.forum.shortnames_depleted?
  end

  def update?
    rule is_super_admin?, super
  end

  def destroy?
    rule is_super_admin?, super
  end
end

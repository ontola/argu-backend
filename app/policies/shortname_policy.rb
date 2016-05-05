class ShortnamePolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  def permitted_attributes
    attributes = super
    attributes << %i(shortname owner_id owner_type) if is_manager_up?
    attributes
  end

  def create?
    r, m = rule is_manager?, is_owner?, super
    return r, m if r && !record.forum.shortnames_depleted?
  end

  def edit?
    rule is_manager?, is_owner?, super
  end

  def update?
    rule is_manager?, is_owner?, super
  end

  def destroy?
    rule is_manager?, is_owner?, super
  end
end

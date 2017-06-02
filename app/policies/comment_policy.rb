# frozen_string_literal: true
class CommentPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(body parent_id) if create?
    attributes
  end

  def create?
    return create_expired? if has_expired_ancestors?
    assert_siblings! if record.try(:parent_id).present?
    rule is_member?, super
  end

  def destroy?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def report?
    rule is_member?, is_manager?, staff?
  end

  def trash?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def untrash?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def update?
    rule is_creator?
  end

  private

  def assert_siblings!
    assert! record.parent_model == record.parent.parent_model, :siblings?
  end
end

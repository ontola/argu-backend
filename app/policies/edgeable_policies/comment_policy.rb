# frozen_string_literal: true

class CommentPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i[body parent_id] if create?
    attributes
  end

  def create?
    assert_siblings! if record.try(:parent_id).present?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def create_expired?
    return unless record.parent_model.is_a?(BlogPost)
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def destroy?
    super unless record.deleted?
  end

  def trash?
    super unless record.deleted?
  end

  def untrash?
    super unless record.deleted?
  end

  def update?
    rule is_creator?
  end

  private

  def assert_siblings!
    assert! record.parent_model == record.parent.parent_model, :siblings?
  end
end

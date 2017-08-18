# frozen_string_literal: true
class CommentPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(body parent_id) if create?
    attributes
  end

  def create?
    assert_siblings! if record.try(:parent_id).present?
    super
  end

  def destroy?
    super unless record.deleted?
  end

  def trash?
    super unless record.deleted?
  end

  private

  def assert_siblings!
    assert! record.parent_model == record.parent.parent_model, :siblings?
  end

  def create_expired?
    return super unless record.parent_model.is_a?(BlogPost)
    grant_available?(:create)
  end
end

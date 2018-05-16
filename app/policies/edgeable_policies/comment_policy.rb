# frozen_string_literal: true

class CommentPolicy < EdgeablePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[body parent_id vote_id]
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

  def untrash?
    super unless record.deleted?
  end

  private

  def assert_siblings!
    assert! record.parent_model == record.parent_comment.parent_model, :siblings?
  end

  def create_expired?
    return super unless record.parent_model.is_a?(BlogPost)
    has_grant?(:create)
  end
end

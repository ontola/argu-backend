# frozen_string_literal: true
class CommentPolicy < EdgeablePolicy
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
    assert! record.parent_model == record.parent.parent_model, :siblings?
  end

  def create_expired?
    record.parent_model.is_a?(BlogPost)
  end
end

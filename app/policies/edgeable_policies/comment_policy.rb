# frozen_string_literal: true

class CommentPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[description in_reply_to_id vote_id]
    attributes
  end

  def create?
    assert_siblings! if record.try(:parent_comment).present?
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
    assert! record.parent == record.parent_comment.parent, :siblings?
  end

  def create_expired?
    return super unless record.parent.is_a?(BlogPost)
    has_grant?(:create)
  end

  def valid_parents_for(klass)
    super + [:comment]
  end
end

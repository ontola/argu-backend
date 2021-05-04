# frozen_string_literal: true

class CommentPolicy < EdgePolicy
  permit_attributes %i[description parent_comment_id vote_id]
  permit_attributes %i[pdf_page pdf_position_x pdf_position_y]

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

  def valid_child?(klass)
    klass == Comment || super
  end
end

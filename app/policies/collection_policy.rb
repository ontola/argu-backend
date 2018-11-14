# frozen_string_literal: true

class CollectionPolicy < RestrictivePolicy
  def create_child?
    parent_policy&.create_child?(record.association_class.name.tableize.to_sym)
  end

  def has_expired_ancestors?
    parent_policy.try(:has_expired_ancestors?)
  end

  def has_trashed_ancestors?
    parent_policy.try(:has_trashed_ancestors?)
  end

  def has_unpublished_ancestors?
    parent_policy.try(:has_unpublished_ancestors?)
  end

  private

  def parent_policy
    return if record.parent.blank?
    if record.parent.is_a?(Edge) && user_context.tree_root_id.nil?
      @parent_policy ||= NoRootPolicy.new(user_context, record.parent)
    end
    @parent_policy ||= Pundit.policy(context, record.parent)
  end
end

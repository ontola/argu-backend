# frozen_string_literal: true

class CollectionPolicy < LinkedRails::CollectionPolicy
  def create_child?
    if parent_policy
      verdict = parent_policy.create_child?(record.association_class.name, collection: record)
      @message = parent_policy.message
    else
      verdict = class_policy.create?
      @message = class_policy.message
    end
    verdict
  end

  def expired?
    has_expired_ancestors?
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

  def show?
    parent_policy.show? || super
  end

  private

  def class_policy
    @class_policy ||= Pundit.policy(user_context, record.association_class.new)
  end

  def parent_policy # rubocop:disable Metrics/AbcSize
    return if record.parent.blank?

    if record.parent.is_a?(Edge) && user_context.tree_root_id.nil?
      @parent_policy ||= NoRootPolicy.new(user_context, record.parent)
    end
    @parent_policy ||= Pundit.policy(context, record.parent)
  end
end

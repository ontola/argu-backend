# frozen_string_literal: true

class BlogPostPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i[title content trashed_at happened_at] if create?
    happening_attributes = %i[id happened_at]
    attributes.append(happening_attributes: happening_attributes)
    append_attachment_params(attributes)
    attributes
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_manager?, is_super_admin?, staff?
  end

  def create_expired?
    is_manager? || is_super_admin? || staff?
  end

  def update?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def feed?
    false
  end
end

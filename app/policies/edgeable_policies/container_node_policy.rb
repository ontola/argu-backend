# frozen_string_literal: true

class ContainerNodePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
        .property_join(:discoverable)
        .with(granted_paths)
        .where(root_id: grant_tree.tree_root_id)
        .where("discoverable_filter.value = true OR #{granted_path_type_filter(parent_type: 'Page')}")
    end
  end

  permit_attributes %i[display_name bio locale]
  permit_nested_attributes %i[grants]

  def create?
    ContainerNode.descendants.detect { |klass| has_grant?(:create, klass.name) }
  end

  def has_content_children?
    false
  end

  def list?
    show?
    true
  end

  def show?
    verdict = super
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || verdict

    verdict
  end

  def new?
    return super unless record.class == ContainerNode

    staff?
  end
end

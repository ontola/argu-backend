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

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name bio bio_long profile_id locale page]
    attributes.append(grants_attributes: %i[id grant_set_id edge_id group_id _destroy])
    attributes.concat %i[discoverable] if staff?
    attributes.concat %i[owner_type] if service?
    attributes
  end

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

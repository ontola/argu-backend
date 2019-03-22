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
    attributes.concat %i[display_name bio bio_long profile_id locale public_grant page]
    attributes.concat %i[discoverable] if staff?
    attributes.concat %i[owner_type] if service?
    attributes
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || show?
    true
  end

  def move?
    staff?
  end
end

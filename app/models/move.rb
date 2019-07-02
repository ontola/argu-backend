# frozen_string_literal: true

class Move < VirtualResource
  include Parentable
  include IRIHelper

  parentable :edge

  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Createable

  attr_accessor :edge, :new_parent

  def canonical_iri_opts
    iri_opts
  end

  def edgeable_record
    @edgeable_record ||= edge
  end

  def edge_id
    edge&.id
  end

  def edge_id=(id)
    @edge = id.present? ? Edge.find_by(uuid: id) : nil
  end

  def identifier
    "move_#{edge.id}_to_#{new_parent.id}"
  end

  def new_parent_id
    new_parent&.id
  end

  def new_parent_id=(id)
    @new_parent = id.present? ? find_parent(id) : nil
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.iri_path)}
  end

  def save
    moved = false
    edge.with_lock do
      moved = edge.move_to new_parent
    end
    moved
  end
  alias save! save

  private

  def find_parent(id)
    ActsAsTenant.without_tenant { uuid?(id) ? Edge.find_by!(uuid: id) : resource_from_iri!(id) }
  end
end

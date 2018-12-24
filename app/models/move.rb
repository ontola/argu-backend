# frozen_string_literal: true

class Move < VirtualResource
  include Parentable
  include IRIHelper

  parentable :edge

  enhance Createable
  enhance Actionable, only: %i[Model]

  attr_accessor :edge, :new_parent

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
    {parent_iri: edge&.iri_path}
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
    uuid?(id) ? Edge.find_by(uuid: id) : resource_from_iri!(id)
  end
end
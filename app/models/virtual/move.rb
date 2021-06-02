# frozen_string_literal: true

class Move < VirtualResource
  include Parentable
  include UUIDHelper

  parentable :edge

  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

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

  def new_parent_id
    new_parent&.id
  end

  def new_parent_id=(id)
    @new_parent = id.present? ? find_parent(id) : nil
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.root_relative_iri)}
  end
  alias canonical_iri_opts iri_opts

  def save
    moved = false
    edge.with_lock do
      moved = edge.move_to(new_parent)
    end
    moved
  end
  alias save! save

  private

  def find_parent(id)
    uuid?(id) ? Edge.find_by!(uuid: id) : LinkedRails.iri_mapper.resource_from_iri!(id, nil)
  end

  class << self
    def attributes_for_new(opts)
      {
        edge: opts[:parent]
      }
    end

    def route_key
      :move
    end
  end
end

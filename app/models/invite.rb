# frozen_string_literal: true

class Invite < VirtualResource
  include Parentable

  enhance LinkedRails::Enhancements::Actionable, only: %i[Model]

  parentable :edge

  enhance LinkedRails::Enhancements::Createable

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
    "invite_#{edge.id}"
  end

  def iri_opts
    {parent_iri: edge&.iri_path}
  end
end

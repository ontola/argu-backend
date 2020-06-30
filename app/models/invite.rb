# frozen_string_literal: true

class Invite < VirtualResource
  include Parentable

  enhance LinkedRails::Enhancements::Actionable, only: %i[Model]

  parentable :edge

  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :edge, :new_parent, :addresses, :message, :group_id, :redirect_url, :send_mail, :root_id

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

  def canonical_iri_opts
    {parent_iri: split_iri_segments(edge&.iri_path)}
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.iri_path)}
  end
end

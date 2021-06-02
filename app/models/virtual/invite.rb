# frozen_string_literal: true

class Invite < VirtualResource
  include Parentable

  enhance LinkedRails::Enhancements::Actionable, only: %i[Model]

  parentable :edge

  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :edge, :new_parent, :creator, :addresses, :message, :group_id, :redirect_url, :send_mail, :root_id

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
    {parent_iri: split_iri_segments(edge&.root_relative_iri)}
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.root_relative_iri)}
  end

  class << self
    def attributes_for_new(opts)
      attrs = {
        edge: opts[:parent],
        message: I18n.t('tokens.discussion.default_message', resource: opts[:parent].display_name),
        redirect_url: opts[:parent].iri.to_s,
        root_id: ActsAsTenant.current_tenant,
        send_mail: true
      }
      attrs[:creator] = opts[:user_context]&.user&.iri
      attrs
    end
  end
end

# frozen_string_literal: true

class Invite < VirtualResource
  include Parentable

  parentable :edge

  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :edge, :new_parent, :creator, :addresses, :message, :group_id, :redirect_url, :send_mail, :root_id,
                :max_usages, :expires_at
  attr_writer :token_type

  enum token_type: {bearer_type: 1, email_type: 2}

  validates :token_type, presence: true

  def edgeable_record
    @edgeable_record ||= edge
  end

  def edge_id
    edge&.id
  end

  def edge_id=(id)
    @edge = id.present? ? Edge.find_by(uuid: id) : nil
  end

  def granted_groups_iri
    return if edge.persisted_edge.blank?

    GrantedGroup.collection_iri(
      parent_iri: split_iri_segments(edge.persisted_edge.root_relative_iri)
    )
  end

  def identifier
    "invite_#{edge.id}"
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.root_relative_iri)}
  end

  def token_type
    @token_type || :bearer_type
  end

  class << self
    def attributes_for_new(opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      groups = opts[:user_context]&.grant_tree&.granted_groups(opts[:parent]) if opts[:parent]

      attrs = {
        edge: opts[:parent],
        group_id: groups.find_by(deletable: false)&.iri,
        message: I18n.t('invites.default_message', resource: opts[:parent].display_name),
        redirect_url: opts[:parent].iri.to_s,
        root_id: ActsAsTenant.current_tenant&.uuid,
        max_usages: 1,
        expires_at: 1.week.from_now,
        send_mail: true
      }
      attrs[:creator] = opts[:user_context]&.user&.iri
      attrs
    end
  end
end

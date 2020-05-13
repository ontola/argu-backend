# frozen_string_literal: true

class LinkedRecord < Edge
  enhance LinkedRails::Enhancements::Actionable
  enhance Argumentable
  enhance Commentable
  enhance Opinionable
  enhance VoteEventable

  extend UriTemplateHelper
  extend UUIDHelper

  alias_attribute :display_name, :identifier

  validates :deku_id, presence: true

  parentable :open_data_portal

  property :deku_id, :string, NS::SCHEMA[:sameAs]

  VOTE_OPTIONS = %i[pro neutral con].freeze unless defined?(VOTE_OPTIONS)

  def default_vote_event
    @default_vote_event ||= super || VoteEvent.new(
      parent: self,
      is_published: true,
      starts_at: Time.current,
      creator_id: creator.id,
      publisher_id: publisher.id,
      root_id: root_id
    )
  end

  def voteable
    self
  end

  def iri_opts
    @iri_opts ||= {container_node_id: parent.url, linked_record_id: deku_id}
  end

  def self.new_for_forum(organization_shortname, forum_shortname, id) # rubocop:disable Metrics/MethodLength
    raise(ActiveRecord::RecordNotFound) unless uuid?(id)

    forum =
      Page
        .find_via_shortname!(organization_shortname)
        .container_nodes
        .joins(:shortname)
        .find_by(shortnames: {shortname: forum_shortname})
    raise(ActiveRecord::RecordNotFound) if forum.nil?

    forum.children.new(
      is_published: true,
      publisher: User.community,
      creator: Profile.community,
      owner_type: name,
      deku_id: id,
      root: forum.root
    )
  end

  def self.create_for_forum(organization_shortname, forum_shortname, id)
    record = new_for_forum(organization_shortname, forum_shortname, id)
    ActsAsTenant.with_tenant(record.root) { record.save! }
    record
  end

  def root_relative_canonical_iri(opts = {})
    RDF::URI(super.to_s.sub('/od/', '/lr/'))
  end

  def root_relative_iri(opts = {})
    RDF::URI(super.to_s.sub('/od/', '/lr/'))
  end

  def to_param
    deku_id
  end
end

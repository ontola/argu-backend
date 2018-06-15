# frozen_string_literal: true

class LinkedRecord < Edge
  enhance Commentable
  enhance Argumentable
  enhance Commentable

  include Voteable
  extend UriTemplateHelper
  extend UUIDHelper

  alias_attribute :display_name, :identifier

  validates :deku_id, presence: true

  parentable :forum

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

  def iri(opts = {})
    RDF::URI(super.to_s.sub('/od/', '/lr/'))
  end

  def iri_opts
    @iri_opts ||= {root_id: root.url, forum_id: ancestor(:forum).url, linked_record_id: deku_id}
  end

  def self.new_for_forum(organization_shortname, forum_shortname, id)
    raise(ActiveRecord::RecordNotFound) unless uuid?(id)
    forum =
      Page
        .find_via_shortname!(organization_shortname)
        .forums
        .joins(:shortname)
        .find_by(shortnames: {shortname: forum_shortname})
    raise(ActiveRecord::RecordNotFound) if forum.nil?
    forum.children.new(
      is_published: true,
      publisher: User.community,
      creator: Profile.community,
      owner_type: name,
      deku_id: id
    )
  end

  def self.create_for_forum(organization_shortname, forum_shortname, id)
    record = new_for_forum(organization_shortname, forum_shortname, id)
    record.save!
    record
  end

  def to_param
    deku_id
  end
end

# frozen_string_literal: true

class LinkedRecord < Edgeable::Base
  include Commentable
  include Voteable
  include Argumentable
  extend UriTemplateHelper
  extend UUIDHelper

  alias_attribute :display_name, :identifier

  validates :deku_id, presence: true

  parentable :forum

  VOTE_OPTIONS = %i[pro neutral con].freeze unless defined?(VOTE_OPTIONS)

  def creator
    Profile.community
  end

  def default_vote_event
    @default_vote_event ||= edge.default_vote_event || VoteEvent.new(
      edge: Edge.new(parent: edge, user: publisher, is_published: true),
      starts_at: Time.current,
      creator_id: creator.id,
      publisher_id: publisher.id
    )
  end

  def voteable
    self
  end

  def iri(opts = {})
    RDF::URI(super.to_s.sub('/od/', '/lr/'))
  end

  def iri_opts
    @iri_opts ||= {organization: parent_model(:page).url, forum: parent_model(:forum).url, linked_record_id: deku_id}
  end

  def self.new_for_forum(organization_shortname, forum_shortname, id)
    raise(ActiveRecord::RecordNotFound) unless uuid?(id)
    forum =
      Page
        .find_via_shortname!(organization_shortname)
        .forums
        .joins(:shortname)
        .find_by(shortnames: {shortname: forum_shortname})
    edge = forum.edge.children.new(is_published: true, user_id: User::COMMUNITY_ID)
    new(deku_id: id, edge: edge)
  end

  def self.create_for_forum(organization_shortname, forum_shortname, id)
    record = new_for_forum(organization_shortname, forum_shortname, id)
    record.save!
    record
  end

  def publisher
    User.community
  end

  def to_param
    deku_id
  end
end

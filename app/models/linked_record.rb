# frozen_string_literal: true
class LinkedRecord < ApplicationRecord
  include Argumentable, Voteable, Parentable, Ldable

  belongs_to :page
  belongs_to :source
  alias_attribute :display_name, :title

  before_save :fetch_record
  validates :iri, presence: true, uniqueness: true
  validates :page, presence: true
  validates :source, presence: true

  contextualize_with_id { |r| Rails.application.routes.url_helpers.linked_record_url(r, protocol: :https) }
  contextualize :title, as: 'schema:name'

  parentable :source

  VOTE_OPTIONS = [:pro, :neutral, :con].freeze

  def fetch_record
    response = JSON.parse(HTTParty.get(iri).body)
    self.title = response['title']
  end

  def creator
    Profile.first
  end

  def default_vote_event
    return @default_vote_event if @default_vote_event
    @default_vote_event = VoteEvent.joins(:edge).where(edges: {parent_id: edge.id}).find_by(group_id: -1)
    @default_vote_event ||= VoteEvent.create!(
      edge: Edge.new(parent: edge, user: User.first),
      starts_at: DateTime.current,
      creator: Profile.first,
      publisher: User.first
    )
    @default_vote_event
  end

  def publisher
    User.first
  end
end

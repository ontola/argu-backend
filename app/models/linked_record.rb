# frozen_string_literal: true
class LinkedRecord < ApplicationRecord
  include Argumentable, Voteable, Edgeable, Commentable, Ldable

  belongs_to :page
  belongs_to :source
  alias_attribute :display_name, :title

  validates :iri, presence: true, uniqueness: true
  validates :page, presence: true
  validates :source, presence: true

  contextualize_as_type 'argu:LinkedRecord'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.linked_record_url(r, protocol: :https) }
  contextualize :title, as: 'schema:name'
  contextualize :record_type, as: 'schema:additionalType'

  parentable :source

  VOTE_OPTIONS = [:pro, :neutral, :con].freeze

  def self.find_or_fetch_by_iri(iri)
    record = LinkedRecord.find_or_initialize_by(iri: iri) do |linked_record|
      source = Source.find_by_iri!(iri)
      linked_record.source = source
      linked_record.edge = Edge.new(parent: source.edge, user_id: User::COMMUNITY_ID, is_published: true)
      linked_record.page = source.page
      linked_record.fetch
    end
    existing = LinkedRecord.find_by(iri: record.iri) if record.iri != iri
    existing || record.save && record
  end

  def fetch
    result = HTTParty.get(iri, verify: false, headers: {'Accept' => 'application/vnd.api+json'})
    return unless result.code == 200
    response = JSON.parse(result.body)
    return if response['data'].try(:[], 'attributes').blank?
    self.title = response['data']['attributes']['title'] || response['data']['attributes']['name']
    self.record_type = response['data']['attributes']['@type'] || response['data']['type']
    self.iri = response['data']['attributes']['@id'] if response['data']['attributes']['@id'].present?
  rescue JSON::ParserError, OpenSSL::SSL::SSLError => e
    Bugsnag.notify(e)
  end

  def creator
    Profile.community
  end

  def default_vote_event
    return @default_vote_event if @default_vote_event
    @default_vote_event = VoteEvent.joins(:edge).where(edges: {parent_id: edge.id}).find_by(group_id: -1)
    @default_vote_event ||= VoteEvent.create!(
      edge: Edge.new(parent: edge, user: User.community),
      starts_at: DateTime.current,
      creator: Profile.community,
      publisher: User.community
    )
    @default_vote_event
  end

  def publisher
    User.community
  end
end

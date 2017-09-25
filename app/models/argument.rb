# frozen_string_literal: true

class Argument < Edgeable::Content
  include VotesHelper
  include ProCon
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  belongs_to :publisher, class_name: 'User'

  counter_cache arguments_pro: {pro: true}, arguments_con: {pro: false}
  filterable option: {key: :pro, values: {yes: true, no: false}}
  paginates_per 10

  validate :assert_tenant

  delegate :page, to: :forum

  contextualize_as_type 'argu:Argument'
  contextualize_with_id { |m| Rails.application.routes.url_helpers.argument_url(m, protocol: :https) }
  contextualize :name, as: 'schema:name'
  contextualize :text, as: 'schema:text'
  contextualize :pro, as: 'schema:option'
  contextualize :path, as: 'argu:path'

  def assert_tenant
    return if parent_model.is_a?(LinkedRecord) || forum == parent_model.forum
    errors.add(:forum, I18n.t('activerecord.errors.models.arguments.attributes.forum.different'))
  end

  def default_vote_event
    self
  end

  # http://schema.org/description
  def description
    content
  end

  def next(show_trashed = false)
    adjacent(false, show_trashed)
  end

  # @return [TODO, nil] The id of the previous item or nil.
  def previous(show_trashed = false)
    adjacent(true, show_trashed)
  end

  def adjacent(direction, _show_trashed = nil)
    return if is_trashed?
    ids = parent_model
            .arguments
            .untrashed
            .order("cast(edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
            .ids
    index = ids.index(self[:id])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    parent_model.arguments.find_by(id: p_id)
  end

  def upvote(user, profile)
    service = CreateVote.new(
      edge,
      attributes: {
        for: :pro,
        creator: profile
      },
      options: {
        creator: profile,
        publisher: user
      }
    )
    service.on(:create_vote_failed) do
      raise 'Failed to upvote'
    end
    service.commit
  end

  def remove_upvote(user, profile)
    service = DestroyVote.new(
      upvote_for(self, profile),
      options: {
        creator: profile,
        publisher: user
      }
    )
    service.on(:destroy_vote_failed) do
      raise 'Failed to remove upvote'
    end
    service.commit
  end

  def voteable
    self
  end
end

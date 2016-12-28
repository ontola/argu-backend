# frozen_string_literal: true
class Argument < ApplicationRecord
  include Loggable, ProCon, Flowable, Ldable
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  belongs_to :publisher, class_name: 'User'

  counter_cache arguments_pro: {pro: true}, arguments_con: {pro: false}
  paginates_per 10

  validate :assert_tenant

  scope :argument_comments, lambda {
    includes(:comment_threads)
      .order("edges.children_counts -> 'votes_pro' DESC")
      .references(:comment_threads)
  }

  contextualize_as_type 'argu:Argument'
  contextualize_with_id { |m| Rails.application.routes.url_helpers.argument_url(m, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :content, as: 'schema:text'
  contextualize :pro, as: 'schema:option'

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
    ids = parent_model.arguments_plain.joins(:edge).order("edges.children_counts -> 'votes_pro' DESC").ids
    index = ids.index(self[:id])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    parent_model.arguments.find_by(id: p_id)
  end

  def voteable
    self
  end
end

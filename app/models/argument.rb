# frozen_string_literal: true
class Argument < ApplicationRecord
  include Loggable, ProCon, Flowable
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  belongs_to :publisher, class_name: 'User'

  counter_culture :motion,
                  column_name: proc { |a| a.is_trashed ? nil : "argument_#{a.key}_count" },
                  column_names: {
                    ['pro = ? AND arguments.is_trashed = ?', true, false] => 'argument_pro_count',
                    ['pro = ? AND arguments.is_trashed = ?', false, false] => 'argument_con_count'
                  }
  paginates_per 10

  validate :assert_tenant

  scope :argument_comments, -> { includes(:comment_threads).order(votes_pro_count: :desc).references(:comment_threads) }

  def assert_tenant
    return if forum == motion.forum
    errors.add(:forum, I18n.t('activerecord.errors.models.arguments.attributes.forum.different'))
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
    ids = motion.arguments_plain.order(votes_pro_count: :desc).ids
    index = ids.index(self[:id])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    motion.arguments.find_by(id: p_id)
  end
end

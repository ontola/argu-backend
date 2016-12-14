# frozen_string_literal: true
class Phase < ApplicationRecord
  include Placeable, Parentable
  attr_accessor :finish_phase

  belongs_to :forum
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  validates :forum, presence: true
  validates :creator, presence: true
  validate :end_date_after_start_date

  # For Rails 5 attributes
  # attribute :name, :string
  # attribute :description, :text
  # attribute :integer, :position
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  alias_attribute :display_name, :name
  attr_accessor :end_time

  before_save :update_date_of_project_or_next_phase

  parentable :project
  counter_cache true

  def end_date_after_start_date
    return unless start_date.present? && end_date.present? && end_date < start_date
    errors.add(:end_date, "can't be before start date")
  end

  def end_time
    end_date.present? ? end_date.strftime('%T') : '23:59:59'
  end

  def next_phase
    @next_phase ||= parent_model.phases.where('id > ?', id).try(:first)
  end

  def previous_phase
    @previous_phase ||= parent_model.phases.where('id < ?', id).try(:last)
  end

  def update_date_of_project_or_next_phase
    return unless end_date_changed?
    next_phase.present? ? next_phase.update!(start_date: end_date + 1.second) : parent_model.update!(end_date: end_date)
  end

  # Activities with *.happened key that happened during this phase
  # @param [Boolean] show_unpublished Set to true to include unpublished happenings
  # @return [ActiveRecord::Relation] Activities with *.happened key
  def happenings(show_unpublished = false)
    return Activity.none if start_date.nil?
    if end_date.present?
      parent_model
        .happenings
        .published(show_unpublished)
        .where(created_at: start_date..end_date)
        .order(created_at: :asc)
    else
      parent_model
        .happenings
        .published(show_unpublished)
        .where('created_at > ?', start_date)
        .order(created_at: :asc)
    end
  end
end

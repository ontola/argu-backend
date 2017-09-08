# frozen_string_literal: true

class Phase < Edgeable::Base
  attr_accessor :finish_phase

  belongs_to :forum
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  validates :forum, presence: true
  validates :creator, presence: true
  validate :end_date_after_start_date

  alias_attribute :display_name, :name
  attr_accessor :end_time

  before_save :update_date_of_project_or_next_phase

  parentable :project
  counter_cache true

  contextualize_as_type 'argu:Phase'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.phase_url(r, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :description, as: 'schema:text'

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
  # @return [ActiveRecord::Relation] Activities with *.happened key
  def happenings
    return Activity.none if start_date.nil?
    if end_date.present?
      parent_model
        .happenings
        .where(activities: {created_at: start_date..end_date})
        .order('activities.created_at ASC')
    else
      parent_model
        .happenings
        .where('activities.created_at > ?', start_date)
        .order('activities.created_at ASC')
    end
  end
end

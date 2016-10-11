# frozen_string_literal: true
class Project < ApplicationRecord
  include Placeable, Flowable, Trashable, HasLinks, BlogPostable, ActivePublishable,
          Parentable, Photoable, Loggable, Timelineable, PublicActivity::Common

  # For Rails 5 attributes
  # attribute :title, :string
  # attribute :content, :text
  # attribute :state, :integer, default: 0  # enum
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  # attribute :achieved_end_date, :datetime
  # attribute :email, :string
  # attribute :trashed_at, :datetime

  alias_attribute :display_name, :title
  alias_attribute :description, :content

  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :forum, inverse_of: :projects
  belongs_to :publisher, class_name: 'User'

  has_many :motions, inverse_of: :project, dependent: :nullify
  has_many :top_motions, -> { where(question_id: nil).trashed(false).order(updated_at: :desc) }, class_name: 'Motion'
  has_many :phases, -> { order(:id) }, inverse_of: :project, dependent: :destroy
  has_many :stepups, as: :record, dependent: :destroy
  has_many :questions, inverse_of: :project, dependent: :nullify
  has_many :top_questions, -> { trashed(false).order(updated_at: :desc) }, class_name: 'Question'
  has_many :activities, -> { order(:created_at) }, as: :trackable

  accepts_nested_attributes_for :phases, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :stepups, reject_if: :all_blank, allow_destroy: true

  before_save :update_start_date_of_first_phase

  def self.counter_culture_opts
    {
      column_name: proc { |model| model.is_published && !model.is_trashed? ? 'projects_count' : nil },
      column_names: {
        ['projects.is_published = ? AND projects.trashed_at IS NULL', true] => 'projects_count'
      }
    }
  end
  counter_culture :forum, counter_culture_opts
  parentable :forum

  validates :content, presence: true, length: {minimum: 2, maximum: 5000}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :forum, :creator, :start_date, presence: true

  def current_phase
    phases.where('start_date < ?', Time.current).last
  end

  def in_last_phase?
    phases.where('end_date IS NULL').count == 1
  end

  def top_discussions
    (top_motions + top_questions).sort { |a, b| b.updated_at <=> a.updated_at }
  end

  def update_start_date_of_first_phase
    return unless phases.present? && (start_date_changed? || phases.first.changed?)
    if phases.first.persisted?
      phases.first.update!(start_date: start_date)
    else
      phases.first.start_date = start_date
    end
  end
end

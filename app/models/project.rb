# frozen_string_literal: true

class Project < ApplicationRecord
  include PublicActivity::Common
  include Timelineable
  include Loggable
  include Photoable
  include Edgeable
  include ActivePublishable
  include BlogPostable
  include HasLinks
  include Trashable

  alias_attribute :display_name, :title
  alias_attribute :description, :content

  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :forum, inverse_of: :projects
  belongs_to :publisher, class_name: 'User'

  has_many :motions, dependent: :nullify
  has_many :top_motions,
           -> { where(question_id: nil).published.untrashed.order(updated_at: :desc) },
           class_name: 'Motion'
  has_many :phases, -> { order(:id) }, dependent: :destroy
  has_many :questions, dependent: :nullify
  has_many :top_questions, -> { published.untrashed.order(updated_at: :desc) }, class_name: 'Question'
  has_many :activities, -> { order(:created_at) }, as: :trackable

  accepts_nested_attributes_for :phases, reject_if: :all_blank, allow_destroy: true

  before_save :update_start_date_of_first_phase

  counter_cache true
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

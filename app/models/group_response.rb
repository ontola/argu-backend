# frozen_string_literal: true
# @todo Convert GroupResponses to Opinions, later drop GroupResponses table

class GroupResponse < ApplicationRecord
  include Parentable, Loggable, PublicActivity::Model

  belongs_to :group
  belongs_to :forum
  belongs_to :motion
  # The profile under which name the GroupResponse is displayed
  # Same as `creator`
  belongs_to :creator, class_name: 'Profile'
  # Physical creator of the GroupReponse (the one responsible).
  belongs_to :publisher, class_name: 'User'

  parentable :motion, :forum

  enum side: {pro: 1, neutral: 0, con: 2}

  validates :text, length: {maximum: 5000}
  validates :side, :group, :forum, :motion, :creator, presence: true

  before_destroy :destroy_notifications

  def destroy_notifications
    activities.each do |activity|
      activity.notifications.destroy_all
    end
  end

  def display_name
    text
  end
end

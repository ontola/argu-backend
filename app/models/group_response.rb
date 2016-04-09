
class GroupResponse < ActiveRecord::Base
  include ArguBase, Parentable, PublicActivity::Model

  belongs_to :group
  belongs_to :forum
  belongs_to :motion
  # The profile under which name the GroupResponse is displayed
  # Same as `creator`
  belongs_to :creator, class_name: 'Profile'
  # Physical creator of the GroupReponse (the one responsible).
  belongs_to :publisher, class_name: 'User'
  has_many :activities, as: :trackable

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

  def self.ordered (coll=[])
    dest = {'pro' => {collection: []}, 'neutral' => {collection: []}, 'con' => {collection: []}}
    coll.each { |gr| dest[gr.side][:collection] << gr }
    dest
  end

  def self.ordered_with_meta (coll=[], profile, obj, group)
    collection = {}
    collection[:collection] = ordered(coll)
    collection[:responses_left] = if group.include?(profile)
                                    if group.max_responses_per_member == -1
                                      Float::INFINITY
                                    else
                                      group.max_responses_per_member - obj.responses_from(profile, group)
                                    end
                                  else
                                    0
                                  end
    collection
  end
end

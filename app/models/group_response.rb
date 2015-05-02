
class GroupResponse < ActiveRecord::Base
  include ArguBase, Parentable

  belongs_to :group
  belongs_to :forum
  belongs_to :motion
  belongs_to :profile
  belongs_to :created_by, class_name: 'Profile'

  parentable :motion, :forum

  enum side: {pro: 1, neutral: 0, con: 2}

  validates :text, length: {maximum: 5000}
  validates_presence_of :side, :group, :forum, :motion, :profile

  def creator
    self.profile
  end

  def self.ordered (coll=[])
    dest = {'pro' => {collection: []}, 'neutral' => {collection: []}, 'con' => {collection: []}}
    coll.each { |gr| dest[gr.side][:collection] << gr }
    dest
  end

  def self.ordered_with_meta (coll=[], profile, obj, group)
    collection = {}
    collection[:collection] = ordered(coll)
    collection[:responses_left] = group.max_responses_per_member == -1 ? Float::INFINITY : group.max_responses_per_member - obj.responses_from(profile)
    collection
  end
end

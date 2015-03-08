
class GroupResponse < ActiveRecord::Base
  include ArguBase, Parentable

  belongs_to :group
  belongs_to :forum
  belongs_to :motion
  belongs_to :profile
  belongs_to :created_by, class_name: 'Profile'

  parentable :motion, :forum

  enum side: {pro: 1, neutral: 0, con: 2}

  def creator
    self.profile
  end

  def self.ordered (coll=[])
    dest = {'pro' => {collection: []}, 'neutral' => {collection: []}, 'con' => {collection: []}}
    coll.each { |gr| dest[gr.side][:collection] << gr }
    dest
  end
end

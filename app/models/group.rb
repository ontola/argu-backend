class Group < ActiveRecord::Base
  include ArguBase

  belongs_to :forum
  has_many :group_memberships
  has_many :pages, through: :group_memberships
  has_many :group_responses


  def display_name
    self.name
  end

  def self.ordered (coll=[])
    grouped = coll.group_by { |g| g.group }
    grouped.keys.map { |g| {g => GroupResponse.ordered(grouped[g]) } }.reduce(&:merge) || []
  end

end

include HasRestfulPermissions

class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument
	has_many :votes

	has_paper_trail

	attr_accessible :pro, :statement_id, :argument_id, :votes

	validates_presence_of :statement
	validates_presence_of :argument

	validates_uniqueness_of :statement_id, :scope => [:argument_id]
	validates_uniqueness_of :argument_id, :scope => [:statement_id]

public
	def voted_by?(user)
		!(self.votes.find_by_user_id(user.id).nil?) unless user.nil?
	end

	def get_vote(user)
		self.votes.find_by_user_id(user.id) unless user.nil?
	end

	def num_of_votes
		self.votes.count
	end
end
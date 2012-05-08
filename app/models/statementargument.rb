include HasRestfulPermissions

class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument, :counter_cache => :votes_count
	has_many :votes

	has_restful_permissions

	attr_accessible :pro, :statement_id, :argument_id, :votes

	validates_presence_of :statement
	validates_presence_of :argument

	validates_uniqueness_of :statement_id, :scope => [:argument_id]
	validates_uniqueness_of :argument_id, :scope => [:statement_id]

	def creatable_by?(user)
    	Settings['permissions.create.statementargument'] >= user.clearance unless user.clearance.nil?
	end
	def updatable_by?(user)
		Settings['permissions.update.statementargument'] >= user.clearance unless user.clearance.nil?
	end
	def destroyable_by?(user)
		Settings['permissions.destroy.statementargument'] >= user.clearance unless user.clearance.nil?
	end

	def voted_by?(user)
		!(self.votes.find_by_user_id(user.id).nil?)
	end

	def get_vote(user)
		self.votes.find_by_user_id(user.id) unless user.nil?
	end

	def num_of_votes
		self.votes.count
	end
end
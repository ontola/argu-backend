include HasRestfulPermissions

class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument
	has_many :vote

	has_restful_permissions

	attr_accessible :pro, :statement_id, :argument_id

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

	def votes
		self.vote.count
	end
end
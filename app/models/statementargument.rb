class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument

	attr_accessible :pro, :statement_id, :argument_id

	validates_presence_of :statement
	validates_presence_of :argument

	validates_uniqueness_of :statement_id, :scope => [:argument_id]
	validates_uniqueness_of :argument_id, :scope => [:statement_id]
end
class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument

	attr_accessible :pro, :statement, :argument
end
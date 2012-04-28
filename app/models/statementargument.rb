class Statementargument < ActiveRecord::Base
	belongs_to :statement
	belongs_to :argument

	attr_accessible :pro, :statement_id, :argument_id
end
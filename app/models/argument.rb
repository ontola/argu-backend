class Argument < ActiveRecord::Base
	has_many :statementarguments
	has_many :statements, :through => :statementarguments

	attr_accessible :content, :title, :argtype, :statements
end

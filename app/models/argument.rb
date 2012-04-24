class Argument < ActiveRecord::Base
	belongs_to :statement
	attr_accessible :content, :title, :argtype
end

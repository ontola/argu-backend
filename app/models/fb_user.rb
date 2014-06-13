class FbUser < ActiveRecord::Base
	has_one :user
	#attr_accessible :email, :gender, :id, :locale, :picture, :fb_user_id
end

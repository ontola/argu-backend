module StaticPagesHelper
	def new_pages
		Statement.where("created_at >= ?", Time.now.beginning_of_day)
	end

end

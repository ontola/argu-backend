module ArgumentsHelper
private
	def getBestComment(argument)
		@comment = argument.root_comments[0]
	end

  def print_references(argument)
    content_tag :ol do
      @argument.references.each do |ref|
        if ref[0].blank?
          concat content_tag :li, content_tag(:p, ref[1], id: ref[2])
        else
          concat content_tag :li, link_to(ref[1].present? ? ref[1] : ref[0], '//' + ref[0], id: ref[2])
        end
      end
    end
  end
end

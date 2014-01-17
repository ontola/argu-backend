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

  def pro_translation
    %w(pro true).index(params[:pro] || @argument.pro.to_s) ? t("arguments.pro") : t("arguments.con")
  end

  def back_to_statement
    concat content_tag 'h1', t('arguments.new.header', side: pro_translation)
    link_to @argument.statement.title, statement_path(@argument.statement), class: "title statement top"
  end
end
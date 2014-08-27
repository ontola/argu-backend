include ActsAsTaggableOn::TagsHelper
module StatementsHelper
  def back_to_statement(resource)
    concat content_tag 'h1', t("#{resource.class.name.pluralize.downcase}.new.header", side: pro_translation(resource))
    link_to resource.statement.title, statement_path(resource.statement), class: "title statement top"
  end

  def pro_side(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? "pro" : "con"
  end

  def pro_translation(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? t("#{resource.class.to_s.pluralize.downcase}.pro") : t("#{resource.class.to_s.pluralize.downcase}.con")
  end
end

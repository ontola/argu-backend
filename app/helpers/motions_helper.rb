include ActsAsTaggableOn::TagsHelper
module MotionsHelper
  def back_to_motion(resource)
    concat content_tag 'h1', t("#{resource.class_name}.new.header", side: pro_translation(resource))
    link_to resource.motion.title, motion_path(resource.motion), class: "btn btn-white"
  end

  def pro_side(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? "pro" : "con"
  end

  def pro_translation(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? t("#{resource.class.to_s.pluralize.downcase}.pro") : t("#{resource.class.to_s.pluralize.downcase}.con")
  end

  def progress_bar_width(model, side)
    supplemented_values = [model.votes_pro_percentage < 5 ? 5 : model.votes_pro_percentage,
                           model.votes_neutral_percentage < 5 ? 5 : model.votes_neutral_percentage,
                           model.votes_con_percentage < 5 ? 5 : model.votes_con_percentage]
    overflow = supplemented_values.inject(&:+) - 100
    return supplemented_values[0] - (overflow*(model.votes_pro_percentage/100.to_f)) if side == :pro
    return supplemented_values[1] - (overflow*(model.votes_neutral_percentage/100.to_f)) if side == :neutral
    return supplemented_values[2] - (overflow*(model.votes_con_percentage/100.to_f)) if side == :con
  end
end

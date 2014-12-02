module ArgumentsHelper
private

  # Generates radio array for a model
  # @param model, instance of the item
  def radio_values_for_pro_con(model)
    values = []
    [:pro, :con].each do |side|
      is_checked = side == (model.pro ? :pro : :con)
      values << [t("#{model.class_name}.form.side.#{side}"), side, {checked: is_checked, class: "#{'checked' if is_checked}"}]
    end
    values
  end

  def print_references(argument)
    if argument.references.present?
      concat content_tag :p, t("arguments.references") + ":", class: 'referencestitle'
      content_tag :ol do
        argument.references.each do |ref|
          if ref[0].blank?
            concat content_tag :li, content_tag(:p, ref[1], id: ref[2])
          else
            concat content_tag :li, link_to(ref[1].present? ? ref[1] : ref[0], '//' + ref[0], id: ref[2])
          end
        end
      end
    end
  end

end
# frozen_string_literal: true
module ArgumentsHelper
  # Generates radio array for a model
  # @param model [Model] instance of the item
  def radio_values_for_pro_con(model)
    values = []
    [:pro, :con].each do |side|
      is_checked = side == (model.pro ? :pro : :con)
      values << [
        t("#{model.class_name}.form.side.#{side}"),
        side,
        {checked: is_checked, class: ('checked' if is_checked).to_s}
      ]
    end
    values
  end

  # Note: only used in widget view and opinions view
  def print_references(argument)
    return unless argument.references.present?
    concat content_tag :p, t('arguments.references') + ':', class: 'references-title'
    content_tag :ol, class: 'references-list' do
      argument.references.each do |ref|
        if ref[0].blank?
          concat content_tag :li, content_tag(:p, ref[1], id: ref[2])
        else
          concat content_tag :li, link_to(ref[1].present? ? ref[1] : ref[0], ref[0], id: ref[2], target: '_blank')
        end
      end
    end
  end
end

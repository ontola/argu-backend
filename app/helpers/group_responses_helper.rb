module GroupResponsesHelper

  def radio_values_for_sides(model)
    values = []
    model.class.sides.each do |side, v|
      is_checked = side == model.side
      values << [t("#{model.class_name}.form.side.#{side}"), side, {checked: is_checked, class: "#{'checked' if is_checked}"}]
    end
    values
  end

  def header_values(group)
    {'pro' => t('groupresponses.header.pro', type: group.name), 'neutral' => t('groupresponses.header.neutral', type: group.name), 'con' => t('groupresponses.header.con', type: group.name)}
  end

end
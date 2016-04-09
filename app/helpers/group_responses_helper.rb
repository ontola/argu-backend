module GroupResponsesHelper
  def radio_values_for_sides(model)
    values = []
    model.class.sides.keys.each do |side|
      is_checked = side == model.side
      values << [t("#{model.class_name}.form.side.#{side}"), side, {checked: is_checked, class: ('checked' if is_checked).to_s}]
    end
    values
  end

  def header_values(group)
    {'pro' => t('group_responses.header.pro', type: group.name), 'neutral' => t('group_responses.header.neutral', type: group.name), 'con' => t('group_responses.header.con', type: group.name)}
  end

  def group_responses_left(motion)
    max = motion.group.max_responses_per_member
    if max != -1
     max - motion.responses_from(current_profile, motion.group)
    else
      Float::INFINITY
    end
  end
end

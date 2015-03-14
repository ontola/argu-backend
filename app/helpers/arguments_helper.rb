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
      concat content_tag :p, t("arguments.references") + ":", class: 'references-title'
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

def argument_items(argument)
  if active_for_user?(:notifications, current_user)
    divided = true
    link_items = []
    if current_profile.following?(argument)
      link_items << link_item(t('forums.unfollow'), follows_path(argument_id: argument.id), fa: 'times', divider: 'top', data: {method: 'delete', 'skip-pjax' => 'true'})
    else
      link_items << link_item(t('forums.follow'), follows_path(argument_id: argument.id), fa: 'check', divider: 'top', data: {method: 'create', 'skip-pjax' => 'true'})
    end
    dropdown_options('argument', [{items: link_items}], fa: 'fa-gear')
  end
end

end
# frozen_string_literal: true

class VoteActionList < EdgeActionList
  include VotesHelper

  has_action(
    :create,
    create_options.merge(
      image: -> { create_image },
      label: -> { create_label },
      submit_label: -> { create_label }
    )
  )

  private

  def filtered_resource?
    resource.is_a?(Collection) && resource.filtered?
  end

  def create_image
    return 'fa-plus' unless filtered_resource?

    "fa-#{icon_for_side(resource.filter['option'])}"
  end

  def create_label
    return I18n.t("#{association}.type_new") unless filtered_resource?
    I18n.t("#{association}.instance_type.#{resource.filter['option']}")
  end
end

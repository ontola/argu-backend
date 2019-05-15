# frozen_string_literal: true

class VoteActionList < EdgeActionList
  include VotesHelper

  private

  def filtered_resource?
    resource.is_a?(Collection) && resource.filtered?
  end

  def create_image
    return super unless filtered_resource?
    "fa-#{icon_for_side(resource.filter['option'])}"
  end

  def create_label
    return I18n.t("#{association}.type_new") unless filtered_resource?
    I18n.t("#{association}.instance_type.#{resource.filter['option']}")
  end

  def create_submit_label
    create_label
  end
end

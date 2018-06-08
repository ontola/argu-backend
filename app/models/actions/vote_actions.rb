# frozen_string_literal: true

module Actions
  class VoteActions < EdgeActions
    include VotesHelper

    private

    def filtered_resource?
      resource.is_a?(Collection) && resource.filter.present?
    end

    def new_image
      return super unless filtered_resource?
      "fa-#{icon_for_side(resource.filter['option'])}"
    end

    def new_label
      return I18n.t("#{association}.type_new") unless filtered_resource?
      I18n.t("#{association}.instance_type.#{resource.filter['option']}")
    end
  end
end

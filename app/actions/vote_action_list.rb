# frozen_string_literal: true

class VoteActionList < EdgeActionList
  include VotesHelper

  has_action(
    :create,
    create_options.merge(
      image: -> { create_image(resource.filter['option']) },
      label: -> { create_label(resource.filter['option']) },
      submit_label: -> { create_label(resource.filter['option']) },
      favorite: -> { resource.filter['option'].present? }
    )
  )
  %i[yes no other].each do |option|
    has_action(
      :"create_#{option}",
      create_options.merge(
        image: -> { create_image(option) },
        label: -> { create_label(option) },
        submit_label: -> { create_label(option) },
        favorite: -> { resource.parent.is_a?(VoteEvent) },
        root_relative_iri: -> { resource.new_child(filter: {option: option}).action(:create).iri_path }
      )
    )
  end

  private

  def filtered_resource?
    resource.is_a?(Collection) && resource.filtered?
  end

  def create_image(option)
    return 'fa-plus' unless filtered_resource?

    "fa-#{icon_for_side(option)}"
  end

  def create_label(option)
    return I18n.t("#{association}.type_new") unless filtered_resource?
    I18n.t("#{association}.instance_type.#{option}")
  end
end

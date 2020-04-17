# frozen_string_literal: true

class VoteActionList < EdgeActionList
  include VotesHelper

  has_action(
    :create,
    create_options.merge(
      image: -> { create_image(resource.filter[NS::SCHEMA[:option].to_s]) },
      label: -> { create_label(resource.filter[NS::SCHEMA[:option].to_s]) },
      submit_label: -> { create_label(resource.filter[NS::SCHEMA[:option].to_s]) },
      favorite: -> { resource.filter[NS::SCHEMA[:option].to_s].present? }
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
        root_relative_iri: lambda do
          resource.new_child(filter: {NS::SCHEMA[:option].to_s => [option]}).action(:create).iri_path
        end,
        url: -> { create_url(option) }
      )
    )
  end

  private

  def create_image(option)
    return 'fa-plus' unless option

    "fa-#{icon_for_side(option)}"
  end

  def create_label(option)
    return I18n.t("#{association}.type_new") unless option

    I18n.t("#{association}.instance_type.#{option}")
  end

  def create_url(option)
    iri = resource.unfiltered_collection.iri.dup
    iri.query = {NS::SCHEMA[:option] => option}.to_query
    iri
  end
end

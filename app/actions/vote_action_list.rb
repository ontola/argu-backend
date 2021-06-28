# frozen_string_literal: true

class VoteActionList < EdgeActionList
  include VotesHelper

  has_collection_create_action(
    image: -> { create_image(resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?) },
    label: -> { create_label(resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?) },
    submit_label: -> { create_label(resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?) },
    favorite: lambda {
      resource.filter[NS.schema.option].present? && (
        !resource.parent.upvote_only? || resource.filter[NS.schema.option] == %i[yes]
      )
    }
  )

  has_resource_trash_action(
    image: -> { create_image(resource.option, resource.parent.upvote_only?) },
    label: -> { create_label(resource.option, resource.parent.upvote_only?) },
    submit_label: -> { create_label(resource.option, resource.parent.upvote_only?) }
  )
  has_singular_trash_action(
    image: -> { create_image(resource.option, resource.parent.upvote_only?) },
    label: -> { create_label(resource.option, resource.parent.upvote_only?) },
    submit_label: -> { create_label(resource.option, resource.parent.upvote_only?) }
  )

  private

  def create_image(option, upvote_only = false)
    return 'fa-arrow-up' if upvote_only
    return 'fa-plus' unless option

    "fa-#{icon_for_side(option)}"
  end

  def create_label(option, upvote_only = false)
    return I18n.t('actions.pro_arguments.create_vote.submit') if upvote_only
    return I18n.t("#{association}.type_new") unless option

    I18n.t("#{association}.instance_type.#{option}")
  end

  def create_url(option)
    iri = resource.unfiltered_collection.iri.dup
    iri.query = {NS.schema.option => option}.to_query
    iri
  end
end

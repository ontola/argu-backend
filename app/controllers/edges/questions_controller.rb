# frozen_string_literal: true

class QuestionsController < DiscussionsController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Question.svg')
  )

  private

  def changes_triples
    return super unless motion_collection_changed?

    super + [[current_resource.collection_iri(:motions), NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]]
  end

  def motion_collection_changed?
    current_resource.previous_changes.key?(:default_motion_sorting) ||
      current_resource.previous_changes.key?(:default_motion_display)
  end
end

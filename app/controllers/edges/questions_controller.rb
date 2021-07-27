# frozen_string_literal: true

class QuestionsController < DiscussionsController
  private

  def changes_triples
    return super unless motion_collection_changed?

    super + [[current_resource.motion_collection.iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]]
  end

  def motion_collection_changed?
    current_resource.previous_changes.key?(:default_motion_sorting) ||
      current_resource.previous_changes.key?(:default_motion_display)
  end
end

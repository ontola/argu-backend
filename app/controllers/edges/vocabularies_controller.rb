# frozen_string_literal: true

class VocabulariesController < EdgeableController
  private

  def changes_triples
    return super unless term_collection_changed?

    super + [[current_resource.collection_iri(:terms), NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]]
  end

  def term_collection_changed?
    current_resource.previous_changes.key?(:default_term_display)
  end
end

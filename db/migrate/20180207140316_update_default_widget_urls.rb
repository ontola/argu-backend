class UpdateDefaultWidgetUrls < ActiveRecord::Migration[5.1]
  include UriTemplateHelper

  def change
    Widget.motions.each do |w|
      w.update(
        resource_iri: expand_uri_template(
          'motions_collection_iri',
          parent_iri: split_iri_segments(w.owner.iri(only_path: true)),
          type: :paginated
        )
      )
    end
    Widget.questions.each do |w|
      w.update(
        resource_iri: expand_uri_template(
          'questions_collection_iri',
          parent_iri: split_iri_segments(w.owner.iri(only_path: true)),
          type: :paginated
        )
      )
    end
  end
end

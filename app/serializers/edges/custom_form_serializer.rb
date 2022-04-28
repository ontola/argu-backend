# frozen_string_literal: true

class CustomFormSerializer < EdgeSerializer
  with_collection :custom_form_fields, predicate: NS.argu[:customFormFields]

  statements :field_statements

  def self.field_statements(object, _params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return [] unless object.persisted?

    pages_iri = RDF::URI("#{object.iri}#pages")
    page_iri = RDF::URI("#{object.iri}#page")
    groups_iri = RDF::URI("#{object.iri}#groups")
    group_iri = RDF::URI("#{object.iri}#group")

    [
      [object.iri, NS.form[:pages], page_iri],
      [page_iri, NS.rdfv.type, RDF.Seq],
      [page_iri, RDF[:_0], pages_iri],
      [pages_iri, NS.rdfv.type, NS.form[:Page]],
      [pages_iri, NS.form[:groups], groups_iri],
      [groups_iri, NS.rdfv.type, RDF.Seq],
      [groups_iri, RDF[:_0], group_iri],
      [group_iri, NS.rdfv.type, NS.form[:Group]],
      [group_iri, NS.form[:fields], object.fields_iri]
    ]
  end
end

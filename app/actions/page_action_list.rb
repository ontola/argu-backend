# frozen_string_literal: true

class PageActionList < EdgeActionList
  private

  def create_iri_path
    expand_uri_template(:new_iri, parent_iri: 'o')
  end

  def create_label
    I18n.t('websites.type_new')
  end

  def create_url
    RDF::DynamicURI(LinkedRails.iri(path: '/o'))
  end
end

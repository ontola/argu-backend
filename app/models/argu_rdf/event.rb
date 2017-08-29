# frozen_string_literal: true

module ArguRDF
  class Event < RDFResource
    with_collection :agenda_items,
                    predicate: RDF::Vocabulary.new('https://github.com/argu-co/popolo-ori#').agendaItems,
                    pagination: false,
                    association_class: AgendaItem,
                    collection_class: ArguRDF::Collection

    def model_name
      ActiveModel::Name.new(self.class, nil, 'Event')
    end
  end
end

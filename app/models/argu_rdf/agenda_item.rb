# frozen_string_literal: true

module ArguRDF
  class AgendaItem < RDFResource
    contextualize :title, as: 'schema:name'

    paginates_per 20

    def model_name
      ActiveModel::Name.new(self.class, nil, 'AgendaItem')
    end
  end
end

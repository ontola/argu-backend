# frozen_string_literal: true

module ArguRDF
  class AgendaItem < RDFResource
    def model_name
      ActiveModel::Name.new(self.class, nil, 'AgendaItem')
    end
  end
end

# frozen_string_literal: true

class InfoDocument < VirtualResource
  attr_accessor :iri, :json

  def canonical_iri
    iri
  end

  def header
    json['header']
  end

  def sections
    json['sections'].map.with_index { |values, ind| Section.new(values.merge(iri: RDF::URI("#{iri}##{ind}"))) }
  end

  def title
    json['title']
  end

  class Section < VirtualResource
    attr_accessor :type, :fill, :right, :avatar, :header, :body, :image, :social, :iri, :people, :id, :link, :partners

    def canonical_iri
      iri
    end
  end
end

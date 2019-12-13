# frozen_string_literal: true

class Vocabulary < LinkedRails::Vocabulary
  extend NamesHelper
  extend SerializationHelper

  def cache_resource?
    true
  end

  class << self
    def add_class_data(klass, iri)
      add_class_icon(iri, klass)
      super
    end

    def add_class_icon(iri, klass)
      icon = icon_for(klass)
      return if icon.blank?

      @graph << RDF::Statement.new(iri, NS::SCHEMA[:image], RDF::URI("http://fontawesome.io/icon/#{icon}"))
    end

    def add_subclasses(iri, klass)
      parent =
        if ![Edge, ApplicationRecord].include?(klass.superclass)
          klass.superclass.iri
        elsif klass.include?(Edgeable::Content)
          NS::SCHEMA[:CreativeWork]
        else
          NS::SCHEMA[:Thing]
        end
      @graph << RDF::Statement.new(iri, NS::RDFS[:subClassOf], parent.is_a?(Array) ? parent.first : parent)
    end

    def user_context
      @user_context ||= create_user_context(%w[guest afe])
    end
  end
end
# frozen_string_literal: true

Dir['/argu/*.rb'].each { |file| require file }

RDF::SCHEMA = RDF::Vocabulary.new('http://schema.org/')
RDF::ARGU = RDF::Vocabulary.new('https://argu.co/ns/core#')

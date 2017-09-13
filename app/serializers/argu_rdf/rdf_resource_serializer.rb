# frozen_string_literal: true

module ArguRDF
  class RDFResourceSerializer < BaseSerializer
    include RDFSerializer

    attributes :id
  end
end

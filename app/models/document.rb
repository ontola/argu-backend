# frozen_string_literal: true

class Document < ApplicationRecord
  validates :name, length: {minimum: 4, maximum: 100}
  validates :title, length: {minimum: 4, maximum: 100}

  private

  def iri_opts
    {name: name}
  end

  class << self
    def iri
      NS.schema.CreativeWork
    end
  end
end

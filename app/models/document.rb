# frozen_string_literal: true

class Document < ApplicationRecord
  validates :name, length: {minimum: 4, maximum: 100}
  validates :title, length: {minimum: 4, maximum: 100}

  def to_html
    self.class.markdown_renderer.render(contents)
  end

  private

  def iri_opts
    {name: name}
  end

  class << self
    def iri
      NS::SCHEMA[:CreativeWork]
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new,
        tables: true,
        fenced_code_blocks: false,
        no_styles: true,
        escape_html: true
      )
    end
  end
end

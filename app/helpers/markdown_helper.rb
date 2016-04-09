module MarkdownHelper
  def markdown_to_html(markdown)
    Redcarpet::Markdown.new(
      Argu::Render::HTML.new(filter_html: false, escape_html: true, hard_wrap: true),
      {tables: false, fenced_code_blocks: false, no_styles: true, escape_html: true, autolink: true, lax_spacing: true}
    ).render(markdown).html_safe
  end

  def markdown_to_plaintext(markdown)
    require 'redcarpet/render_strip'

    Redcarpet::Markdown.new(
      Redcarpet::Render::StripDown.new,
      {tables: false, fenced_code_blocks: false, no_styles: true, escape_html: true, autolink: false, lax_spacing: true}
    ).render(markdown)
  end
end

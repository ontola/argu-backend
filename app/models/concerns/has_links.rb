module HasLinks
  extend ActiveSupport::Concern
  require 'html_truncator'

  included do
  end

  #TODO escape content=(text)
  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\1">\2</a>')
  end

  def truncate_preview(length, opts= {})
    HTML_Truncator.truncate(supped_content, length, opts)
  end

  module ClassMethods
  end
end
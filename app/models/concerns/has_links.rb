module HasLinks
  extend ActiveSupport::Concern

  included do
  end

  #TODO escape content=(text)
  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\1">\2</a>')
  end

  module ClassMethods
  end
end
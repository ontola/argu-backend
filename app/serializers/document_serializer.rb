# frozen_string_literal: true

class DocumentSerializer < BaseSerializer
  attribute :title, predicate: NS::SCHEMA[:name]
  attribute :contents, predicate: NS::SCHEMA[:text]

  def contents
    object.contents.gsub('//argu', '//app.argu')
  end
end

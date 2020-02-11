# frozen_string_literal: true

class InfoDocumentSerializer < BaseSerializer
  attribute :header, predicate: NS::SCHEMA[:text]
  attribute :title, predicate: NS::SCHEMA[:name]
  has_many :sections, predicate: NS::ARGU[:sections]

  class SectionSerializer < BaseSerializer
    attribute :type, predicate: NS::ARGU[:type]
    attribute :fill, predicate: NS::ARGU[:fill]
    attribute :right, predicate: NS::ARGU[:right]
    attribute :avatar, predicate: NS::ARGU[:avatar]
    attribute :header, predicate: NS::ARGU[:header]
    attribute :body, predicate: NS::ARGU[:body]
    attribute :image, predicate: NS::ARGU[:image]
    attribute :social, predicate: NS::ARGU[:social]
    attribute :people, predicate: NS::ARGU[:people]
    attribute :link, predicate: NS::ARGU[:link]
    attribute :partners, predicate: NS::ARGU[:partners]
  end
end

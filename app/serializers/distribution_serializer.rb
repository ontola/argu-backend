# frozen_string_literal: true

class DistributionSerializer < EdgeSerializer
  attribute :access_url, predicate: NS::DCAT[:accessURL]
  attribute :description, predicate: NS::DC[:description]
  attribute :format, predicate: NS::DC[:format]
  attribute :license, predicate: NS::DC[:license]
  attribute :byte_size, predicate: NS::DCAT[:byteSize]
  # attribute :checksum, predicate: NS::SPDX[:checksum]
  attribute :page, predicate: NS::FOAF[:page]
  attribute :download_url, predicate: NS::DCAT[:downloadURL]
  attribute :language, predicate: NS::DC[:language]
  attribute :conforms_to, predicate: NS::DC[:conformsTo]
  attribute :media_type, predicate: NS::DCAT[:mediaType]
  attribute :issued, predicate: NS::DC[:issued]
  attribute :rights, predicate: NS::DC[:rights]
  attribute :status, predicate: NS::ADMS[:status]
  attribute :display_name, predicate: NS::DC[:title]
  attribute :modified, predicate: NS::DC[:modified]
end

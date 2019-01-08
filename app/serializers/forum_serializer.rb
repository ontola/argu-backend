# frozen_string_literal: true

class ForumSerializer < EdgeSerializer
  attribute :bio, predicate: NS::SCHEMA[:description]
  attribute :bio_long, predicate: NS::SCHEMA[:text]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :language, predicate: NS::SCHEMA[:language], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :public_grant, predicate: NS::ARGU[:publicGrant]

  enum :public_grant,
       type: GrantSet.iri,
       options: Hash[
         [:none].concat(GrantSet::SELECTABLE_TITLES).map do |title|
           [title.to_sym, {iri: NS::ARGU["grantSet#{title}"], label: I18n.t("roles.types.#{title}")}]
         end
       ]
end

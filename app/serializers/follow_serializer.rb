# frozen_string_literal: true

class FollowSerializer < RecordSerializer
  belongs_to :followable, predicate: NS.schema.isPartOf
  attribute :text, predicate: NS.schema.text do |object|
    I18n.t("follows.status.#{object.follow_type}", item: object.followable.display_name)
  end
  enum :follow_type, predicate: NS.argu[:followType]
end

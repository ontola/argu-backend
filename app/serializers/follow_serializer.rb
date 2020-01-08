# frozen_string_literal: true

class FollowSerializer < RecordSerializer
  belongs_to :followable, predicate: NS::SCHEMA.isPartOf
  attribute :text, predicate: NS::SCHEMA.text

  def created_at; end

  def display_name; end

  def published_at; end

  def text
    I18n.t("follows.status.#{object.follow_type}", item: object.followable.display_name)
  end
end

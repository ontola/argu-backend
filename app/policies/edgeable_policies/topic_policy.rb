# frozen_string_literal: true

class TopicPolicy < DiscussionPolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description]
    attributes
  end

  def move?
    staff? || administrator? || moderator?
  end
end

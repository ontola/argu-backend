# frozen_string_literal: true

class ArgumentPolicy < EdgePolicy
  include VotesHelper

  def class_name
    'ProArgument'
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description pro]
    attributes
  end

  def up_vote?
    upvote_for(record, user.profile).blank?
  end

  def down_vote?
    upvote_for(record, user.profile).present?
  end
end

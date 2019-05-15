# frozen_string_literal: true

class MotionActionList < EdgeActionList
  private

  def create_action_favorite
    association.to_sym == :votes
  end
end

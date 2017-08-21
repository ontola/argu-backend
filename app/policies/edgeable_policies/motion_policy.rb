# frozen_string_literal: true
class MotionPolicy < EdgeablePolicy
  def convert?
    has_grant_set?('staff')
  end

  def statistics?
    has_grant_set?(%w(moderator administrator staff))
  end
end

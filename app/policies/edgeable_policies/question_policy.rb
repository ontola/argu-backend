# frozen_string_literal: true
class QuestionPolicy < EdgeablePolicy
  def convert?
    has_grant_set?('staff')
  end
end

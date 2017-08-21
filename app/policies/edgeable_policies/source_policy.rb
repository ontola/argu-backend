# frozen_string_literal: true
class SourcePolicy < EdgeablePolicy
  def settings?
    update?
  end
end

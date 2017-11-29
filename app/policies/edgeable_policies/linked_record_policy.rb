# frozen_string_literal: true

class LinkedRecordPolicy < EdgeablePolicy
  def destroy?
    false
  end
end

# frozen_string_literal: true

class LinkedRecordPolicy < EdgePolicy
  def destroy?
    false
  end
end

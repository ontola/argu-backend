# frozen_string_literal: true
class LinkedRecordPolicy < EdgeTreePolicy
  def show?
    rule is_member?, is_manager?, is_owner?, super
  end
end

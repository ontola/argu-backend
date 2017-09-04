# frozen_string_literal: true

class LinkedRecordPolicy < EdgeablePolicy
  def show?
    rule is_spectator?, is_member?, is_manager?, is_super_admin?, super
  end
end

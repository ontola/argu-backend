# frozen_string_literal: true

class CreateDecision < CreateEdge
  private

  def after_save
    notify
  end
end

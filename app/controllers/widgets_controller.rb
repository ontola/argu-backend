# frozen_string_literal: true

class WidgetsController < ServiceController
  private

  def resource_new_params
    {owner: parent_resource}
  end
end

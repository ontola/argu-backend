# frozen_string_literal: true

class CurrentActorsController < ApplicationController
  active_response :show

  private

  def show_includes
    %i[profile_photo user actor]
  end
end

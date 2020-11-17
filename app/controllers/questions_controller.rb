# frozen_string_literal: true

class QuestionsController < DiscussionsController
  include VotesHelper

  private

  def show_params
    params.permit(:page)
  end
end

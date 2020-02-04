# frozen_string_literal: true

class QuestionsController < DiscussionsController
  include VotesHelper
  skip_before_action :check_if_registered, only: :index

  private

  def show_params
    params.permit(:page)
  end
end

# frozen_string_literal: true

class SearchController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource, :show?
  end

  def index_association
    skip_verify_policy_scoped(true)
    SearchResult.new(
      page: params[:page],
      parent: parent_resource,
      q: params[:q],
      user_context: user_context
    )
  end

  def index_success_html
    skip_verify_policy_scoped(true)
    redirect_to parent_resource!
  end

  def index_includes
    [results: :members]
  end
end

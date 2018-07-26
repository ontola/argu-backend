# frozen_string_literal: true

class ListItemsController < ParentableController
  skip_before_action :check_if_registered, only: :index

  private

  def index_collection_name
    "#{params[:relationship].to_s.singularize}_collection"
  end
end

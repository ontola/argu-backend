# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    skip_before_action :authorize_action, only: %i[index]

    private

    def index_collection
      current_user.page_collection(collection_options)
    end

    def user
      return @user if @user.present?

      @user = User.find_via_shortname! params[:id]
      authorize @user, :update?
      @user
    end
  end
end

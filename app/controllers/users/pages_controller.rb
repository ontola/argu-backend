# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    skip_before_action :authorize_action, only: %i[index]

    def index
      @user = User.find_via_shortname! params[:id]
      authorize @user, :update?
      @pages = policy_scope(Page)
                 .where(id: @user.profile.granted_record_ids(owner_type: 'Page')
                              .concat(@user.profile.pages.pluck(:id)))
                 .distinct

      render locals: {
        current: current_user.profile.pages.length,
        max: policy(current_user).max_allowed_pages
      }
    end
  end
end

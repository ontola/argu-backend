# frozen_string_literal: true

class DiscussionsController < ParentableController
  active_response :new
  skip_before_action :check_if_registered

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def new_success
    return respond_with_form(default_form_options(:new)) if %i[html js].include?(active_response_type)
    respond_with_resource(
      resource: parent_resource!.menu(user_context, :discussions),
      include: [menu_sequence: [members: [:image, menu_sequence: [members: [:image]]]]]
    )
  end

  def show_includes
    {default_cover_photo: {}, creator: :default_profile_photo}
  end

  def resource_by_id; end

  def resource_new_params
    HashWithIndifferentAccess.new(forum: parent_resource!)
  end
end

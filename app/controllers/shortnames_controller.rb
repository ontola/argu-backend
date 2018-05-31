# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  def create
    if execute_update
      create_handler_success(authenticated_resource)
    else
      create_handler_failure(authenticated_resource)
    end
  end

  private

  def authenticated_edge
    authenticated_resource
  end

  def destination_param
    return @destination_param if instance_variable_defined?(:@destination_param)
    return if params[:shortname].try(:[], :destination).blank?
    @destination_param = "#{parent_from_params.iri_path}/#{params[:shortname][:destination]}"
  end

  def handle_record_not_unique_html
    authenticated_resource
      .errors
      .add(:owner, t('activerecord.errors.record_not_unique'))
    respond_with_form(authenticated_resource)
  end

  def parent_resource
    return super if destination_param.blank?
    @parent_resource ||= resource_from_iri(destination_param)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      primary: false,
      owner: parent_resource!,
      root_id: unscoped_param ? nil : parent_resource.root_id
    )
  end

  def redirect_model_success(_resource = nil)
    settings_iri_path(authenticated_resource.root, tab: 'shortnames')
  end

  def respond_with_form(resource)
    render 'pages/settings',
           locals: {
             tab: "shortnames/#{tab}",
             active: 'shortnames',
             shortname: resource,
             resource: resource.parent_model(:page)
           }
  end

  def respond_with_redirect_success(_resource = nil, _action = nil, opts = {})
    redirect_to redirect_model_success, opts
  end

  def tab
    case action_name
    when 'create', 'new'
      :new
    when 'edit', 'update'
      :edit
    end
  end

  def unscoped_param
    params[:shortname].try(:[], :unscoped) if current_user.is_staff?
  end

  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_resource&.root_id
      else
        resource_by_id&.owner&.root_id
      end
  end
end

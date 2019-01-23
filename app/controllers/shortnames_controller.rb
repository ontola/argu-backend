# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  private

  def active_response_action_name(_view)
    ACTION_MAP[action_name.to_sym] || action_name.to_sym
  end

  def destination_param
    return @destination_param if instance_variable_defined?(:@destination_param)
    return if params[:shortname].try(:[], :destination).blank?
    @destination_param = "#{parent_from_params.iri_path}/#{params[:shortname][:destination]}"
  end

  def create_execute
    update_execute
  end

  def find_resource_by_root?(_opts)
    false
  end

  def handle_record_not_unique_html
    authenticated_resource
      .errors
      .add(:owner, t('activerecord.errors.record_not_unique'))
    respond_with_form(default_form_options(nil))
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

  def redirect_location
    settings_iri(authenticated_resource.root, tab: 'shortnames')
  end

  def default_form_view(_action)
    'pages/settings'
  end

  def default_form_view_locals(_action)
    {
      tab: "shortnames/#{tab}",
      active: 'shortnames',
      shortname: authenticated_resource,
      resource: authenticated_resource.root
    }
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
end

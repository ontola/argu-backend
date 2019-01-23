# frozen_string_literal: true

class GroupMembershipsController < ServiceController
  skip_before_action :verify_terms_accepted

  def index # rubocop:disable Metrics/AbcSize
    return super if params[:group_id].present?
    return if params[:q].nil?
    q = params[:q].tr(' ', '|')
    # Matched groups with members
    @results = policy_scope(
      GroupMembership
        .includes(:group, user: [:shortname, :email_addresses, profile: :default_profile_photo])
        .where('groups.root_id = ? AND groups.id > 0', parent_resource!.uuid)
        .where('shortnames.owner_type = ?', 'User')
        .where('lower(groups.name) SIMILAR TO lower(?) OR ' \
               'lower(shortnames.shortname) SIMILAR TO lower(?) OR ' \
               'lower(users.first_name) SIMILAR TO lower(?) OR ' \
               'lower(users.last_name) SIMILAR TO lower(?)',
               "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")
        .references(:groups, :users)
    )

    render json: @results, include: [:group, user: :default_profile_photo]
  end

  private

  def authorize_action
    super unless action_name == 'index' && params[:group_id].blank?
  end

  def create_failure
    if existing_record
      respond_with_invalid_resource(resource: authenticated_resource, status: 304, location: existing_record.iri.to_s)
    else
      Bugsnag.notify(authenticated_resource.errors.full_messages)
      super
    end
  end

  def create_failure_html
    redirect_to redirect_location, notice: t('errors.general')
  end

  def create_success_options_json
    opts = create_success_options
    opts[:include] = :group
    opts[:location] = authenticated_resource!.iri.to_s
    opts
  end

  alias create_service_parent parent_resource!

  def existing_record # rubocop:disable Metrics/AbcSize
    return @existing_record if @existing_record.present?
    return if authenticated_resource.valid?
    duplicate_values = authenticated_resource
                         .errors
                         .details
                         .select { |_key, errors| errors.select { |error| error[:error] == :taken }.any? }
                         .map { |key, errors| [key, errors.find { |error| error[:error] == :taken }[:value]] }
    @existing_record = controller_class
                         .find_by(Hash[duplicate_values].merge(member_id: authenticated_resource.member_id))
  end

  def new_success_html
    respond_with_redirect location: settings_iri_path(authenticated_resource.group, tab: :invite)
  end

  def parent_resource_key(opts)
    action_name == 'index' ? super : :group_id
  end

  def permit_params
    params.permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def resource_new_params
    {
      group: parent_resource!
    }
  end

  def redirect_param
    params.permit(:r)[:r]
  end

  def redirect_location # rubocop:disable Metrics/AbcSize
    return redirect_param if redirect_param.present?
    forum_grants = authenticated_resource!.grants.joins(:edge).where(edges: {owner_type: 'Forum'})
    return forum_grants.first.edge.iri_path if forum_grants.count == 1
    authenticated_resource!.page.iri_path
  end
  alias destroy_success_location redirect_location

  def show_success_html
    flash.keep
    respond_with_redirect(location: redirect_location)
  end
end

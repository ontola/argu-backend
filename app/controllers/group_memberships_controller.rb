# frozen_string_literal: true

class GroupMembershipsController < ServiceController
  skip_before_action :verify_terms_accepted

  private

  def create_failure
    if existing_record
      respond_with_invalid_resource(resource: authenticated_resource, status: 304, location: existing_record.iri.to_s)
    else
      Bugsnag.notify(authenticated_resource.errors.full_messages)
      super
    end
  end

  def create_success_options_json
    opts = create_success_options
    opts[:include] = %i[group]
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

  def permit_params
    params.permit(*policy(requested_resource || new_resource).permitted_attributes)
  end

  def redirect_param
    params.permit(:r)[:r]
  end

  def redirect_location
    return redirect_param if redirect_param.present?

    forum_grants = authenticated_resource!.grants.joins(:edge).where(edges: {owner_type: 'Forum'})
    return forum_grants.first.edge.iri if forum_grants.count == 1

    authenticated_resource!.page.iri
  end
  alias destroy_success_location redirect_location

  def requires_setup?
    false
  end
end

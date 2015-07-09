if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # This block is run in application_controller context,
    # so you have access to all controller methods
    fields[:environment] = Rails.env
    fields[:user] = current_user && current_user.url
    fields[:user_id] = current_user && current_user.id
    fields[:profile] = current_profile && current_profile.url
    fields[:profile_id] = current_profile && current_profile.id
    fields[:ua] = request.env['HTTP_USER_AGENT']
    fields[:a_params] = request.try(:params).try(:slice, 'at', 'r', 'q')
    if (cs = current_context.context_scope(current_profile)).present?
      fields[:forum] = cs.model.url
    end
  end
end

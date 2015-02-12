if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # This block is run in application_controller context,
    # so you have access to all controller methods
    fields[:environment] = Rails.env
    fields[:user] = current_user && current_user.id
    fields[:profile] = current_profile && current_profile.id
    fields[:a_params] = request.try(:params).try(:slice, 'at', 'r', 'q')
    if current_context.has_parent?
      fields[:forum] = current_context.model.get_parent.model.web_url
    end
  end
end
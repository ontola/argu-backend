if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # This block is run in application_controller context,
    # so you have access to all controller methods
    fields[:environment] = Rails.env
    fields[:user] = current_user && current_user.id
    fields[:profile] = current_profile && current_profile.id

  end
end
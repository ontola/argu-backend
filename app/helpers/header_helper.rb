module HeaderHelper

  # Label for the home button
  def home_text
    current_scope.model.try(:display_name)[0..13] + (current_scope.model.try(:display_name)[14] ? "..." : "") || t("home_title")
  end
end
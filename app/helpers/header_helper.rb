module HeaderHelper

  # Label for the home button
  def home_text
    current_scope.model.try(:display_name)[0..11] + (current_scope.model.try(:display_name)[12] ? "..." : "") || t("home_title")
  end
end
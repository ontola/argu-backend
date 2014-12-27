module HeaderHelper

  # Label for the home button
  def home_text
    current_scope.model.try(:display_name) || t("home_title")
  end
end
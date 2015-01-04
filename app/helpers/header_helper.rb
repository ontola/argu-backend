module HeaderHelper

  # Label for the home button
  def home_text
    current_scope.model.try(:display_name) || t("home_title")
  end

  def suggested_forums
    @suggested_forums ||= Forum.where("id NOT IN (#{current_profile.memberships.map(&:forum_id).join(',')}) AND visibility = #{Forum.visibilities[:open]}")
  end
end
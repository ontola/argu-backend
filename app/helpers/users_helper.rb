# frozen_string_literal: true

module UsersHelper
  include UriTemplateHelper

  def accept_terms_param
    params[:accept_terms].to_s == 'true'
  end

  def forum_from_r_action(user) # rubocop:disable Metrics/CyclomaticComplexity
    return if user.r.nil?

    resource = LinkedRails.resource_from_iri(path_to_url(user.r)) if user.r.present?
    return if resource.nil? || resource.is_a?(Page) || !resource.is_fertile?
    return resource if resource.is_a?(Forum)

    resource.ancestor(:forum)
  end

  def r_param
    r = (params[:user]&.permit(:r) || params.permit(:r)).try(:[], :r)
    r if argu_iri_or_relative?(r)
  end

  # Assigns certain favorites based on
  #   either an 'r' action
  #   or preferred_forum
  #   if the user hasn't got any favorites yet
  def setup_favorites(user)
    # changed? so we can safely write back to the DB
    return unless user.valid? && user.persisted?
    return if user.favorites.present?

    begin
      forum = forum_from_r_action(user)
      Favorite.create!(user: user, edge: forum) if forum.present?
    rescue ActiveRecord::RecordNotFound => e
      Bugsnag.notify(e)
    end
  end

  def suggested_shortname(resource)
    shortname = shortname_from_email(resource.email)
    existing = Shortname.where('shortname ~* ?', "^#{shortname}\\d*$").pluck(:shortname).map(&:downcase)
    return shortname unless existing.include?(shortname)

    "#{shortname}#{shortname_gap(existing.map { |s| s[/\d+/].to_i }.sort)}"
  end

  def shortname_from_email(email)
    email[/[^@]+/].tr('.', '_').downcase if email
  end

  def shortname_gap(integers)
    (integers + [integers.last + 1]).inject { |a, e| e == a.next ? e : (break a.next) }
  end
end

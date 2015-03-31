module ApplicationHelper
  include ActivityStringHelper, AlternativeNamesHelper

  # Uses Rollout to determine whether a feature is active for a given User
  def active_for_user?(feature, user)
    begin
      $rollout.active?(feature, user)
    rescue RuntimeError => e
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, {
          :severity => 'error',
      })
    end
  end

  def awesome_time_ago_in_words (date)
    if date.present?
      if 1.day.ago < date
        distance_of_time_in_words(date, Time.now)
      elsif 1.year.ago < date
        date.strftime("%B #{date.day.ordinalize} %H:%M")
      else
        date.strftime('%Y-%m-%d %H:%M')
      end
    end
  end

  # Merges a URI with a params Hash
  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    if params.class != Hash
      params = params.present? ? Hash[*params.split('=')] : Hash.new
    end

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  # Used in forms for the 'r' system
  def remote_if_user
    current_profile.present? ? { remote: true } : {}
  end

  # Used in forms for the 'r' system
  def remote_unless_user
    current_profile.present? ? {} : { remote: true, 'skip-pjax' => true }
  end

  def resource
    @resource
  end

  def set_title(title= "")
    if request.env['HTTP_X_PJAX']
      return raw "<title>#{[title, (' | ' if title), t('name')].compact.join.capitalize}</title>"
    else
      provide :title, title
    end
  end

  # Generates social media links for any resource for HyperDropdown
  def share_items(resource)
    link_items = []
    url = CGI.escape(url_for([resource, only_path: false]))
    #image = resource.display_name
    facebook_url = "https://www.facebook.com/dialog/feed?app_id=#{Rails.application.secrets.facebook_app_id}&display=popup&link=#{url}&redirect_uri=#{url}"
    twitter_url = "https://twitter.com/intent/tweet?url=#{url}&text=#{resource.display_name}%20%23Argu"
    linkedin_url = "http://www.linkedin.com/shareArticle?url=#{url}"


    link_items << link_item('Facebook', facebook_url, fa: 'facebook')
    link_items << link_item('Twitter', twitter_url, fa: 'twitter')
    link_items << link_item('LinkedIn', linkedin_url, fa: 'linkedin')

    dropdown_options(t('share'), [{items: link_items}], fa: 'fa-share')
  end

  def process_cover_photo(object, _params)
    if params[object.class.name.downcase][:cover_photo].present?
      object.assign_attributes(_params.except(:cover_photo))
      if object.valid?
        object.remove_cover_photo!
        return object.save.to_s
      end
    end
    false
  end

  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_path(profile)
    if profile.profileable.class == User
      user_path(profile.profileable)
    elsif profile.profileable.class == Page
      page_path(profile.profileable)
    else
      'deleted'
    end
  end

  # Generates a link to the Profile's profileable edit action
  # Either a Page or a User
  def dual_profile_edit_path(profile)
    if profile.profileable.class == User
      edit_profile_path(profile.profileable)
    elsif profile.profileable.class == Page
      #edit_page_path?
      page_path(profile.profileable)
    else
      'deleted'
    end
  end

  # :nodoc:
  def can_show_display_name?(preview)
    if preview.respond_to?(:get_parent)
      preview.get_parent.model.open?
    elsif preview.class == Profile
      true
    end
  end

end
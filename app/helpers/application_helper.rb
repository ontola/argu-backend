module ApplicationHelper

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

  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    if params.class != Hash
      params = params.present? ? Hash[*params.split('=')] : Hash.new
    end

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  def remote_if_user
    current_profile.present? ? { remote: true } : {}
  end

  def remote_unless_user
    current_profile.present? ? {} : { remote: true }
  end

  def resource
    @resource
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

  def dual_profile_path(profile)
    if profile.owner.class == User
      profile_path(profile.username)
    else
      pages_path(profile.web_url)
    end
  end

  def can_show_display_name?(preview)
    if preview.respond_to?(:get_parent)
      preview.get_parent.model.open?
    elsif preview.class == Profile
      true
    end
  end

end
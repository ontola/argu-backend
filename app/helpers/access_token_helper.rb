module AccessTokenHelper
  def check_for_access_token
    if get_access_token
      grant_viewing_rights_for @access_token
    end
  end

  def grant_viewing_rights_for(item)
    session[:a_tokens] = (session[:a_tokens] || []) << item.access_token
  end

  def has_valid_token?(user=nil)
    !!get_access_token(user)
  end

  def get_access_token(user=nil)
    # Eval is used here, but as long as get_safe_raw_access_tokens is used
    # to set access_tokens on User, it's safe to do so.
    access_token = params[:at].presence || user && eval(user.access_tokens).try(:first).presence
    if access_token.present?
      @access_token = AccessToken.find_by_access_token access_token
    end
  end

  def get_access_tokens(user=nil)
    ((eval(user.access_tokens) if user) || session[:a_tokens]).map { |at| AccessToken.find_by_access_token(at) }
  end

  # This must be done via the database, since it ensures the eval function can be run safely later on
  def get_safe_raw_access_tokens(user=nil)
    get_access_tokens(user).map(&:access_token)
  end
end

# frozen_string_literal: true
# See {AccessToken}
module AccessTokenHelper
  # Calls {AccessTokenHelper#get_access_token} and grants access when a token is found.
  def check_for_access_token
    grant_viewing_rights_for(AccessToken.find_by(access_token: params[:at]), current_user)
  end

  # @private
  def grant_viewing_rights_for(item, user)
    return if item.nil?
    current_access_tokens = get_safe_raw_access_tokens(user)
    return if current_access_tokens.include? item.access_token
    session[:a_tokens] = Set.new(current_access_tokens).add(item.access_token)
    user.update(access_tokens: get_safe_raw_access_tokens(user))
    increment_token_usages(item)
  end

  # Only works after {AccessTokenHelper#check_for_access_token} or grant_viewing_rights_for has been called,
  # since it doesn't read params
  def has_valid_token?(user = nil)
    get_access_tokens(user).present?
  end

  # Checks whether the user has an applicable `access_token` in their session
  # `AccessToken`s trickle down access to their scope
  def has_access_token_access_to(record = nil, user = nil)
    return if record.nil?
    access_tokens = get_access_tokens(user)
    access_tokens.any? do |a_t|
      a_t.item.visible_with_a_link? &&
        (record == a_t.item || (record.try(:is_fertile?) && record.edge.is_child_of?(a_t.item.edge)))
    end
  end

  # Gets access tokens which have been stored in a user model or in the session
  # @param [User] user
  def get_access_tokens(user = nil)
    ats = ((eval(user.access_tokens.to_s) if user) || []) + (session[:a_tokens].to_a || [])
    AccessToken.where(access_token: ats)
  end

  # This must be done via the database, since it ensures the eval function can be run safely later on
  def get_safe_raw_access_tokens(user = nil)
    get_access_tokens(user).pluck(:access_token)
  end

  # @private
  def increment_token_usages(item)
    item.increment! :usages
  end
end

# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer do
    Rails.application.config.origin
  end

  signing_key ENV['OIDC_KEY']&.gsub('\n', "\n")

  subject_types_supported %i[public]

  resource_owner_from_access_token do |access_token|
    UserContext.new(doorkeeper_token: access_token)
  end

  auth_time_from_resource_owner do |user_context|
    user_context.user.current_sign_in_at
  end

  reauthenticate_resource_owner do |user_context, _return_to|
    sign_out user_context.user
    redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  # select_account_for_resource_owner do |resource_owner, return_to|
  #   # Example implementation:
  #   # store_location_for resource_owner, return_to
  #   # redirect_to account_select_url
  # end

  subject do |user_context|
    user_context.user.iri
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  protocol do
    :https
  end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  claims do
    # @return [string] End-User's full name in displayable form including all name parts, possibly including titles and
    # suffixes, ordered according to the End-User's locale and preferences.
    normal_claim :name, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.display_name
    end

    # @return [string] Given name(s) or first name(s) of the End-User. Note that in some cultures, people can have
    # multiple given names; all can be present, with the names being separated by space characters.
    # normal_claim :given_name, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.given_name
    # end

    # @return [string] Surname(s) or last name(s) of the End-User. Note that in some cultures, people can have multiple
    # family names or no family name; all can be present, with the names being separated by space characters.
    # normal_claim :family_name, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.family_name
    # end

    # @return [string] Middle name(s) of the End-User. Note that in some cultures, people can have multiple middle
    # names; all can be present, with the names being separated by space characters. Also note that in some cultures,
    # middle names are not used.
    # normal_claim :middle_name, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.middle_name
    # end

    # @return [string] Casual name of the End-User that may or may not be the same as the given_name. For instance, a
    # nickname value of Mike might be returned alongside a given_name value of Michael.
    # normal_claim :nickname, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.nickname
    # end

    # @return [string] Shorthand name by which the End-User wishes to be referred to at the RP, such as janedoe or
    # j.doe. This value MAY be any valid JSON string including special characters such as @, /, or whitespace. The RP
    # MUST NOT rely upon this value being unique, as discussed in Section 5.7.
    # normal_claim :preferred_username, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.preferred_username
    # end

    # @return [string] URL of the End-User's profile page. The contents of this Web page SHOULD be about the End-User.
    normal_claim :profile, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.iri
    end

    # @return [string] URL of the End-User's profile picture. This URL MUST refer to an image file (for example, a PNG,
    # JPEG, or GIF image file), rather than to a Web page containing an image. Note that this URL SHOULD specifically
    # reference a profile photo of the End-User suitable for displaying when describing the End-User, rather than an
    # arbitrary photo taken by the End-User.
    normal_claim :picture, scope: :openid do |user_context, _scopes, _access_token|
      photo = user_context.user.default_profile_photo
      photo.public_url_for_version('content') unless photo&.gravatar_url?
    end

    # @return [string] URL of the End-User's Web page or blog. This Web page SHOULD contain information published by the
    # End-User or an organization that the End-User is affiliated with.
    # normal_claim :website, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.website
    # end

    # @return [string] End-User's preferred e-mail address. Its value MUST conform to the RFC 5322 [RFC5322] addr-spec
    # syntax. The RP MUST NOT rely upon this value being unique, as discussed in Section 5.7.
    normal_claim :email, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.email
    end

    # @return [boolean] True if the End-User's e-mail address has been verified; otherwise false. When this Claim Value
    # is true, this means that the OP took affirmative steps to ensure that this e-mail address was controlled by the
    # End-User at the time the verification was performed. The means by which an e-mail address is verified is
    # context-specific, and dependent upon the trust framework or contractual agreements within which the parties are
    # operating.
    normal_claim :email_verified, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.confirmed?
    end

    # @return [string] End-User's gender. Values defined by this specification are female and male. Other values MAY be
    # used when neither of the defined values are applicable.
    # normal_claim :gender, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.gender
    # end

    # @return [string] End-User's birthday, represented as an ISO 8601:2004 [ISO8601-2004] YYYY-MM-DD format. The year
    # MAY be 0000, indicating that it is omitted. To represent only the year, YYYY format is allowed. Note that
    # depending on the underlying platform's date related function, providing just year can result in varying month and
    # day, so the implementers need to take this factor into account to correctly process the dates.
    # normal_claim :birthdate, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.birthdate
    # end

    # @return [string] String from zoneinfo [zoneinfo] time zone database representing the End-User's time zone. For
    # example, Europe/Paris or America/Los_Angeles.
    normal_claim :zoneinfo, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.time_zone
    end

    # @return [string] End-User's locale, represented as a BCP47 [RFC5646] language tag. This is typically an ISO 639-1
    # Alpha-2 [ISO639-1] language code in lowercase and an ISO 3166-1 Alpha-2 [ISO3166-1] country code in uppercase,
    # separated by a dash. For example, en-US or fr-CA. As a compatibility note, some implementations have used an
    # underscore as the separator rather than a dash, for example, en_US; Relying Parties MAY choose to accept this
    # locale syntax as well.
    normal_claim :locale, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.language
    end

    # @return [string] End-User's preferred telephone number. E.164 [E.164] is RECOMMENDED as the format of this Claim,
    # for example, +1 (425) 555-1212 or +56 (2) 687 2400. If the phone number contains an extension, it is RECOMMENDED
    # that the extension be represented using the RFC 3966 [RFC3966] extension syntax,
    # for example, +1 (604) 555-1234;ext=5678.
    # normal_claim :phone_number, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.phone_number
    # end

    # @return [boolean] True if the End-User's phone number has been verified; otherwise false. When this Claim Value
    # is true, this means that the OP took affirmative steps to ensure that this phone number was controlled by the
    # End-User at the time the verification was performed. The means by which a phone number is verified is
    # context-specific, and dependent upon the trust framework or contractual agreements within which the parties are
    # operating. When true, the phone_number Claim MUST be in E.164 format and any extensions MUST be represented in
    # RFC 3966 format.
    # normal_claim :phone_number_verified, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.phone_number_verified
    # end

    # @return [JSON] object  End-User's preferred postal address. The value of the address member is a JSON [RFC4627]
    # structure containing some or all of the members defined in Section 5.1.1.
    # normal_claim :address, scope: :openid do |user_context, _scopes, _access_token|
    #   user_context.address
    # end

    # @return [number] Time the End-User's information was last updated. Its value is a JSON number representing the
    # number of seconds from 1970-01-01T0:0:0Z as measured in UTC until the date/time.
    normal_claim :updated_at, scope: :openid do |user_context, _scopes, _access_token|
      user_context.user.updated_at.to_i
    end
  end
end

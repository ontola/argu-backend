# frozen_string_literal: true

class OtpAttempt < OtpSecret
  include NoPersistence

  attr_accessor :session

  def save
    validate_otp_attempt

    errors.empty?
  end

  def iri_opts
    {session: session}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new("/#{route_key}{/id}{?session}{#fragment}")
    end

    def route_key
      'users/otp_attempts'
    end
  end
end

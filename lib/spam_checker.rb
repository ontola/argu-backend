# frozen_string_literal: true

class SpamChecker
  include Rakismet::Model
  attr_accessor :email, :content
  rakismet_attrs user_ip: '0.0.0.0'

  def initialize(opts = {})
    self.email = opts[:email]
    self.content = opts[:content]
  end
end

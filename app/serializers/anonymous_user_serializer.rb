# frozen_string_literal: true

class AnonymousUserSerializer < RecordSerializer
  def self?
    false
  end
end

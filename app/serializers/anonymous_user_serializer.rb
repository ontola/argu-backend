# frozen_string_literal: true

class AnonymousUserSerializer < RecordSerializer
  def self.self?(_object, _params)
    false
  end
end

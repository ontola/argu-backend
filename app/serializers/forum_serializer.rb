# frozen_string_literal: true
class ForumSerializer < RecordSerializer
  include Motionable::Serlializer
  include Questionable::Serlializer
  attributes :display_name, :description
end

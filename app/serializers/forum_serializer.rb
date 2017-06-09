# frozen_string_literal: true
class ForumSerializer < RecordSerializer
  include Motionable::Serializer
  include Questionable::Serializer
  attributes :display_name
end

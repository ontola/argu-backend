# frozen_string_literal: true
class ForumSerializer < RecordSerializer
  include Motionable::Serlializer
  attributes :display_name, :shortname
end

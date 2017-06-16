# frozen_string_literal: true

class ForumSerializer < RecordSerializer
  include Motionable::Serializer
  include Questionable::Serializer
  include Menuable::Serializer
  attributes :display_name
  include_menus
end

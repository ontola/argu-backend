# frozen_string_literal: true

class ForumSerializer < RecordSerializer
  include Menuable::Serializer

  include_menus
end

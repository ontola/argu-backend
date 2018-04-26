# frozen_string_literal: true

class ForumSerializer < RecordSerializer
  include Menuable::Serializer
  include Photoable::Serializer
  include Widgetable::Serializer

  include_menus
end

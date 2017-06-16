# frozen_string_literal: true

class SourceSerializer < RecordSerializer
  include Menuable::Serializer
  attributes :display_name
  include_menus
end

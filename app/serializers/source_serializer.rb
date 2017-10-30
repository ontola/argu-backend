# frozen_string_literal: true

class SourceSerializer < RecordSerializer
  include Menuable::Serializer
  include_menus
end

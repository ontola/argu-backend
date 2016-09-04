class MotionSerializer < BaseSerializer
  include Loggable::Serlializer
  attribute :display_name, key: :title
  attribute :content, key: :text
end

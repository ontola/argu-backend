class Tag < ActsAsTaggableOn::Tag
  ActsAsTaggableOn::Tag.class_eval do
    has_one :statement
  end
end

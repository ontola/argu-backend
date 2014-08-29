class Tag < ActsAsTaggableOn::Tag
  has_one :statement
end

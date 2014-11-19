class Tag < ActsAsTaggableOn::Tag
  ActsAsTaggableOn::Tag.class_eval do
    //@TODO change to some string with a gid
    has_one :motion
  end
end

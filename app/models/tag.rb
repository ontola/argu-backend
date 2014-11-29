class Tag < ActsAsTaggableOn::Tag
  ActsAsTaggableOn::Tag.class_eval do
    include ArguBase
    # @TODO: change to some string with a gid
    has_one :motion
  end

  validates :name, presence: true, length: {minimum: 3, maximum: 10}
end

# frozen_string_literal: true

class BannerDismissal < Edge
  include RedisResource::Concern
  enhance LinkedRails::Enhancements::Creatable
  parentable :banner

  def display_name; end

  def self.store_in_redis?(_opts = {})
    true
  end
end

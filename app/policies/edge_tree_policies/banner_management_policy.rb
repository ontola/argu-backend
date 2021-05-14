# frozen_string_literal: true

class BannerManagementPolicy < BannerPolicy
  class Scope < Scope
    def resolve
      Banner
    end
  end
end

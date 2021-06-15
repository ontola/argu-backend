class RenameBadge < ActiveRecord::Migration[6.0]
  def change
    Edge.where(owner_type: 'CouponBadge').update_all(owner_type: 'CouponBatch')
  end
end

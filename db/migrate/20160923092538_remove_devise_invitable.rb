class RemoveDeviseInvitable < ActiveRecord::Migration[5.0]
  def up
    change_table :users do |t|
      t.remove :invitations_count,
               :invitation_limit,
               :invitation_sent_at,
               :invitation_accepted_at,
               :invitation_token,
               :invitation_created_at,
               :invited_by_id,
               :invited_by_type
    end
  end

  def down
    change_table :users do |t|
      t.string     :invitation_token
      t.datetime   :invitation_created_at
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.integer    :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer    :invitations_count, default: 0
      t.index      :invitation_token, unique: true
    end
  end
end

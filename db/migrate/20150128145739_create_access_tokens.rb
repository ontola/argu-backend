class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.belongs_to :item, polymorphic: true
      t.string :access_token, null: false
      t.belongs_to :profile, null: false
      t.integer :usages, default: 0
      t.timestamps null: false
    end

    add_foreign_key :access_tokens, :profiles
  end
end

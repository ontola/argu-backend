class CreateSpamVerdicts < ActiveRecord::Migration[5.2]
  def change
    create_table :spam_verdicts do |t|
      t.boolean :verdict, null: false
      t.text :content
      t.string :email
      t.hstore :http_headers
      t.string :ip
      t.string :referrer
      t.string :user_agent
    end
  end
end

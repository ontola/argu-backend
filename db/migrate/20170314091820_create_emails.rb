class CreateEmails < ActiveRecord::Migration[5.0]
  def up
    create_table :emails do |t|
      t.integer :user_id, null: false
      t.string :email
      t.boolean :primary, default: false, null: false

      ## Confirmable
      t.string :unconfirmed_email
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.index :email, unique: true
    end
    add_foreign_key :emails, :users

    remove_index :users, column: :email

    # This user does not have an email, so we're destroying it
    User.find(4).destroy!

    User.find_each do |user|
      email = Email.new(
        user: user,
        email: user.attributes['email'],
        primary: true,
        unconfirmed_email: user.attributes['unconfirmed_email'],
        confirmation_token: user.attributes['confirmation_token'],
        confirmed_at: user.attributes['confirmed_at'],
        confirmation_sent_at: user.attributes['confirmation_sent_at']
      )
      email.skip_confirmation!
      email.save!
    end
  end

  def down
    drop_table :emails
    add_index :users, column: :email, unique: true
  end
end

class AddIndexConstraints < ActiveRecord::Migration
  def change
    add_index :profiles, :slug, unique: true

    ##@TODO: Foreign keys seem to be broken in 4.2.0beta4, so when final version arrives, test this again in a new migration
    #add_foreign_key :profiles_roles, :roles, column: :role_id
    #add_foreign_key :profiles_roles, :profiles, column: :profile_id

    add_index :question_answers, [:question_id, :motion_id], unique: true
    #add_foreign_key :question_answers, :questions
    #add_foreign_key :question_answers, :motions

    #add_foreign_key :questions, :forums
    #add_foreign_key :questions, :users, column: :creator_id, primary_key: :users_pkey

    #add_foreign_key :arguments, :motions
    #add_foreign_key :arguments, :users, column: :creator_id, primary_key: :users_pkey

    add_index :forums, :web_url, unique: true
    add_index :forums, :slug, unique: true

    add_index :users, :profile_id, unique: true

    add_index :pages, :profile_id, unique: true
    add_index :pages, :web_url, unique: true
    add_index :pages, :slug, unique: true

    #add_foreign_key :taggings, :tags
  end
end

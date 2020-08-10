# frozen_string_literal: true

class DropFavorites < ActiveRecord::Migration[6.0]
  drop_table(:favorites)
end

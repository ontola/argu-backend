# frozen_string_literal: true
# @private
class ProconCreateProcon < ActiveRecord::Migration
  def change
    create_table :procon do |t|
      t.integer :id
      t.references :procontainer, polymorphic: true
      t.string  :procon_type
      t.string  :content
      t.timestamps
    end
  end
end

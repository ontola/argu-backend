class AddLanguageToForums < ActiveRecord::Migration[5.0]
  def change
    add_column :forums, :locale, :string, default: 'nl-NL'
  end
end

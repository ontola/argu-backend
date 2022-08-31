class MigrateLocales < ActiveRecord::Migration[7.0]
  def change
    I18n.available_locales.each do |locale|
      Property
        .where(predicate: NS.argu[:locale]).where('string LIKE ?', "%#{locale}%")
        .update_all(
          predicate: NS.schema.language,
          string: locale
        )
    end
  end
end

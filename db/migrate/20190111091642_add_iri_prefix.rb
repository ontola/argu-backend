class AddIRIPrefix < ActiveRecord::Migration[5.2]
  def change
    Page.joins(:shortname).find_each do |page|
      page.update(iri_prefix: "app.argu.co/#{page.url}")
    end

    # Drop unused tables
    drop_table :sources
    drop_table :rules
  end
end

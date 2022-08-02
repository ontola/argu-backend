class StoreManifests < ActiveRecord::Migration[7.0]
  def change
    Page.find_each do |page|
      page.manifest.save
    end
  end
end

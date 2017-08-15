class CreateForumCountryPlaces < ActiveRecord::Migration[5.0]
  def up
    pre_count = Placement.count
    Forum.find_each { |forum| forum.send(:reset_country) }
    raise "Missing #{Placement.count - pre_count - Forum.count} placements" unless Placement.count - pre_count == Forum.count
    raise "Missing #{Placement.where(title: 'country').count - Forum.count} placements" unless Placement.where(title: 'country').count == Forum.count
  end
end

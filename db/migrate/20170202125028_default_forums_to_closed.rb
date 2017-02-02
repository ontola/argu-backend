class DefaultForumsToClosed < ActiveRecord::Migration[5.0]
  def change
    # Update invalid forum
    forum = Forum.find_via_shortname('ebu_nom')
    forum.update(bio_long: forum.bio, bio: 'De ambitie: 50.000 ‘nul-op-de-meter’ woningen in 2020.')

    Forum.hidden.find_each do |forum|
      forum.closed!
    end
    Forum.find_via_shortname('argu_intern').hidden!
    Page.hidden.find_each do |page|
      page.closed!
    end

    change_column :forums, :visibility, :integer, default: 2
    change_column :sources, :visibility, :integer, default: 2
  end
end

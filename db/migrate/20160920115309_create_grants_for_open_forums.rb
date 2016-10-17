class CreateGrantsForOpenForums < ActiveRecord::Migration[5.0]
  def up
    Group.create!(id: -1,
                  page: Page.find_via_shortname('argu'),
                  edge: Edge.new(parent: Page.find_via_shortname('argu').edge, user: User.find(0)),
                  deletable: false)

    Forum.open.each { |forum| Grant.create(group_id: -1, role: :member, edge: forum.edge) }
  end

  def down
    Group.find(-1).destroy
  end
end

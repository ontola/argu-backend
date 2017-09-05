class CreateStaffGrantForAllPages < ActiveRecord::Migration[5.1]
  def up
    group =
      Group
        .create!(
          id: Group::STAFF_ID,
          name: 'Staff',
          name_singular: 'Staff member',
          page: Page.find_via_shortname('argu'),
          deletable: false
        )

    shortnames = %w(joep fletcher91 michielvdingh Bart argubot arthur)
    shortnames.each do |shortname|
      gm = GroupMembership.new(
        group: group,
        member: User.find_via_shortname(shortname).profile,
        start_date: DateTime.current
      )
      gm.save!(validate: false)
    end
    raise 'Wrong staff count' unless GroupMembership.where(group_id: Group::STAFF_ID).count == shortnames.count
  end

  def down
    Group.staff.destroy!
  end
end

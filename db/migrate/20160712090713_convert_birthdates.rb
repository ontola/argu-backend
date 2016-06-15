class ConvertBirthdates < ActiveRecord::Migration
  def up
    User.where('birthday IS NOT NULL').find_each do |u|
      u.update(birthday: Date.new(u.birthday.year, 7, 1))
    end
  end
end

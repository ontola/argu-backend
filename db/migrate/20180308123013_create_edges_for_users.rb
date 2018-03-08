class CreateEdgesForUsers < ActiveRecord::Migration[5.1]
  def change
    User.find_each do |u|
      u.send(:build_root_edge)
    end

    VoteMatch.destroy_all
  end
end

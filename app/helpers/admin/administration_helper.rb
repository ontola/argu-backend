module Admin
  ROLES = %w(user mod admin coder)
  module AdministrationHelper
    def select_highest_rank(roles)
      t 'admin.' + highest_rank(roles)
    end

    def highest_rank(roles)
      Admin::ROLES.each { |r| roles.each { |role| return r if role.name == r } }
    end
  end
end
class AddStaffScope < ActiveRecord::Migration[6.1]
  def change
    Doorkeeper::Application.argu.update(scopes: 'guest user staff')
    Doorkeeper::Application.argu_front_end.update(scopes: 'guest user staff')
  end
end

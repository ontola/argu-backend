# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.create(email: 'admin@argu.co', shortname_attributes: {shortname: 'admin_account'}, password: 'arguargu', password_confirmation:'arguargu')
ub = User.create(email: 'staff@argu.co', shortname_attributes: {shortname: 'staff_account'}, password: 'arguargu', password_confirmation:'arguargu')
uc = User.create(email: 'user@argu.co', shortname_attributes: {shortname: 'user_account'}, password: 'arguargu', password_confirmation:'arguargu')

ua.build_profile name: 'Admin Account'
ub.build_profile name: 'Staff Account'
uc.build_profile name: 'User Account'

ua.profile.add_role :staff
ub.profile.add_role :staff
uc.profile.add_role :user

Setting.set('user_cap', -1)
Setting.set('quotes', 'Argumenten moet men wegen, niet tellen.')
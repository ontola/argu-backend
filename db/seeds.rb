# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).


['user', 'moderator', 'admin', 'coder'].each do |role|
  Role.find_or_create_by_name(role).save
end

ua = User.create(email: 'thomvankalkeren@gmail.com', username: 'fletcher91', password: 'foobar', password_confirmation:'foobar' );
ub = User.create(username: 'admin', email: 'postmaster@argu.nl', password:'foobar', password_confirmation:'foobar')

ua.profile = Profile.create(name: 'Thom van Kalkeren', picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ub.profile = Profile.create(name: 'Administrator')

ua.roles << Role.find_by_name('coder')
ub.roles << Role.find_by_name('admin')

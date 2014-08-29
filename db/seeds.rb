# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.find_or_create_by_email(email: 'thomvankalkeren@gmail.com', username: 'fletcher91', password: 'foobar', password_confirmation:'foobar')
ub = User.find_or_create_by_email(username: 'admin', email: 'postmaster@argu.nl', password:'opendebate', password_confirmation:'opendebate')
uc = User.find_or_create_by_email(email: 'joepmeindertsma@gmail.com', username: 'joep', password: 'joepjoep', password_confirmation:'joepjoep')

ua.add_role :coder
ub.add_role :administration
uc.add_role :user

ua.profile = Profile.find_or_create_by_name(name: 'Thom van Kalkeren', picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ub.profile = Profile.find_or_create_by_name(name: 'Administrator')
uc.profile = Profile.find_or_create_by_name(name: 'Joep', picture: 'https://lh5.googleusercontent.com/-fgiBDzie7Jk/UEoCv42lzzI/AAAAAAAABZk/nfYf52duV4o/s518/profielfoto.jpg', about: "argu designer")


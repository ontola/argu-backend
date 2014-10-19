# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.create(email: 'thomvankalkeren@gmail.com', username: 'fletcher91', password: 'foobar', password_confirmation:'foobar')
ub = User.create(username: 'admin', email: 'postmaster@argu.nl', password:'opendebate', password_confirmation:'opendebate')
uc = User.create(email: 'joepmeindertsma@gmail.com', username: 'joep', password: 'joepjoep', password_confirmation:'joepjoep')

ua.add_role :coder
ub.add_role :administration
uc.add_role :user

ua.profile = Profile.create(name: 'Thom van Kalkeren', picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ub.profile = Profile.create(name: 'Administrator')
uc.profile = Profile.create(name: 'Joep', picture: 'https://lh5.googleusercontent.com/-fgiBDzie7Jk/UEoCv42lzzI/AAAAAAAABZk/nfYf52duV4o/s518/profielfoto.jpg', about: "argu designer")


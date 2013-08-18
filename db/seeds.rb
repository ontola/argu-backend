# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.find_or_create(email: 'thomvankalkeren@gmail.com', username: 'fletcher91', password: 'foobar', password_confirmation:'foobar', role: :coder);
ub = User.find_or_create(username: 'admin', email: 'postmaster@argu.nl', password:'opendebate', password_confirmation:'opendebate', role: :admin)
uc = User.find_or_create(email: 'joepmeindertsma@gmail.com', username: 'joep', password: 'joepjoep', password_confirmation:'joepjoep', role: :admin);

ua.profile = Profile.find_or_create(name: 'Thom van Kalkeren', picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ub.profile = Profile.find_or_create(name: 'Administrator')
uc.profile = Profile.find_or_create(name: 'Joep', picture: 'https://lh5.googleusercontent.com/-fgiBDzie7Jk/UEoCv42lzzI/AAAAAAAABZk/nfYf52duV4o/s518/profielfoto.jpg', about: "argu designer")


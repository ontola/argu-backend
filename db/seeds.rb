# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.where(email: 'thomvankalkeren@gmail.com').first_or_create
ua.update_attributes(username: 'fletcher91', password: 'foobar', password_confirmation:'foobar')
ub = User.where(email: 'postmaster@argu.nl').first_or_create
ub.update_attributes(username: 'admin', password:'opendebate', password_confirmation:'opendebate')
uc = User.where(email: 'joepmeindertsma@gmail.com').first_or_create
uc.update_attributes(username: 'joep', password: 'joepjoep', password_confirmation:'joepjoep')


pa = Profile.where(name: 'Thom van Kalkeren').first_or_create.update_attributes(picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ua.profile = pa
pb = Profile.where(name: 'Administrator').first_or_create
ub.profile = pb
pc = Profile.where(name: 'Joep').first_or_create.update_attributes(picture: 'https://lh5.googleusercontent.com/-fgiBDzie7Jk/UEoCv42lzzI/AAAAAAAABZk/nfYf52duV4o/s518/profielfoto.jpg', about: "argu designer")
uc.profile = pc

pa.add_role :coder
pc.add_role :user
pc.add_role :coder


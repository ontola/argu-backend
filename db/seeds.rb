# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ua = User.where(email: 'thomvankalkeren@gmail.com').first_or_create
ub = User.where(email: 'postmaster@argu.nl').first_or_create
uc = User.where(email: 'joepmeindertsma@gmail.com').first_or_create

ua.attributes = {shortname_attributes: {shortname: 'fletcher91'}, password: 'foobar', password_confirmation:'foobar'}
ub.attributes = {shortname_attributes: {shortname: 'admin'}, password:'opendebate', password_confirmation:'opendebate'}
uc.attributes = {shortname_attributes: {shortname: 'user'}, password: 'useruser', password_confirmation:'useruser'}

ua.build_profile name: 'Thom van Kalkeren'
ub.build_profile name: 'Administrator'
uc.build_profile name: 'User'

ua.profile.update_attributes(picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
uc.profile.update_attributes(picture: 'https://lh5.googleusercontent.com/-fgiBDzie7Jk/UEoCv42lzzI/AAAAAAAABZk/nfYf52duV4o/s518/profielfoto.jpg', about: "argu designer")

ua.profile.add_role :staff
ub.profile.add_role :staff
uc.profile.add_role :user


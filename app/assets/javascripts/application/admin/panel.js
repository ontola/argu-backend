$(function () {
  $('.btnaddrole').click(function (e) {
    $('#user_search_form #role').attr('value', $(this).attr('role'));
    $('.addrole').show();
  });
});
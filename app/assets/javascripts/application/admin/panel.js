$(function () {
  $('.btnaddrole').click(function () {
    $('#user_search_form #role').attr('value', $(this).attr('role'));
    $('.addrole').show();
  });
});
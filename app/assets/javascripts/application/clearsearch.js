$(document).ready(function() {
  var inputVal;
  $(document).on('#search', 'blur', function() {
 	inputVal = $(this).val();
 	$(this).val(null);
  });
  $(document).on('#search', 'focus', function() {
 	$(this).val(inputVal);
  });
});
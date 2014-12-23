$(document).ready(function() {
 var inputVal;
 $("#search").blur(function() {
 	inputVal = $("#search").val();
 	$("#search").val(null);
 });
 $("#search").focus(function() {
 	$("#search").val(inputVal);
 });
});
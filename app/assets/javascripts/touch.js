//test for touch events support and if not supported, attach .no-touch class to the HTML tag.
 
if (!("ontouchstart" in document.documentElement)) {
document.documentElement.className += " no-touch";
}
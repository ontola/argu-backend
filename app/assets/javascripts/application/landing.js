for (let item of document.getElementsByClassName("landing__triad-button")) {
  const itemString = item.dataset.triad;

  item.addEventListener("click", () => updateClassName(itemString) )
}

function updateClassName(name) {
  document.getElementById("triad-block").className = `landing__current-triad landing__show-${name}`;
}

function nextHeaderCarousel() {
  const showName = "landing__hero-carousel--current";
  const childNodes = document.getElementById("hero-carousel").childNodes;
  const currentNode = document.querySelector('#hero-carousel .landing__hero-carousel--current');
  const currentIndex = Array.from(childNodes).indexOf(currentNode);
  const nextNode = childNodes[(currentIndex + 1) % childNodes.length];
  currentNode.className = '';
  nextNode.className = showName;
}

setInterval(nextHeaderCarousel, 5000);

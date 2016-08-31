export function replaceHeadElement(elem) {
  const documentHeaderElement = document.getElementById(elem.id);

  if (documentHeaderElement == null || (documentHeaderElement) === 'undefined') {
    document.head.appendChild(elem);
  } else {
    for (let i = 0; i < elem.attributes.length; i++) {
      if (typeof (documentHeaderElement.attributes[elem.attributes[i].name]) !== 'undefined') {
        documentHeaderElement.attributes[elem.attributes[i].name].value = elem.attributes[i].value;
      } else {
        document.head.removeChild(documentHeaderElement);
        document.head.appendChild(elem);
      }
    }
  }
}

export function processContentForMetaTags(_event, contents) {
  const toDelete = [];
  contents.each((i, elem) => {
    if (elem.id === 'meta_content') {
      for (let j = 0; j < elem.children.length; j++) {
        replaceHeadElement(elem.children[j]);
      }
    }
  });
  toDelete.forEach(i => {
    contents.splice(i, 1);
  });
}

export function removeMetaContent() {
  const meta = document.getElementById('meta_content');
  if (meta) {
    if (typeof meta.remove === 'undefined') {
      meta.removeNode();
    } else {
      meta.remove();
    }
  }
}

export default {
  processContentForMetaTags,
  removeMetaContent,
  replaceHeadElement,
};

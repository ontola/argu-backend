function processContentForMetaTags(event, contents, options) {
    "use strict";
    var toDelete = [];
    contents.each((i, elem) => {
        if (elem.id === 'meta_content') {
            for (let j = 0; j < elem.children.length; j++) {
                replaceHeadElement(elem.children[j]);
            }
        }
    });
    toDelete.forEach(function (i) {
        contents.splice(i, 1);
    });
}

function removeMetaContent() {
    "use strict";
    let meta = document.getElementById('meta_content');
    if (meta) {
        typeof meta.remove === 'undefined' ? meta.removeNode() : meta.remove();
    }
}

function replaceHeadElement(elem) {
    "use strict";
    let documentHeaderElement = document.getElementById(elem.id);

    if (documentHeaderElement == null || (documentHeaderElement) === "undefined") {
        document.head.appendChild(elem);
    } else {
        for(let i = 0; i < elem.attributes.length; i++) {
            if (typeof(documentHeaderElement.attributes[elem.attributes[i].name]) !== "undefined") {
                documentHeaderElement.attributes[elem.attributes[i].name].value = elem.attributes[i].value;
            } else {
                document.head.removeChild(documentHeaderElement);
                document.head.appendChild(elem);
            }
        }
    }

}

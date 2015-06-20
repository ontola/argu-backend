function processContentForMetaTags(event, contents, options) {
    "use strict";
    var toDelete = [];
    contents.each((i, elem) => {
        if (elem.id === 'meta_content') {
            replaceMetaTags(elem);
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
        meta.remove();
    }
}

function replaceMetaTags(elem) {
    "use strict";
    var headerItems = document.head.getElementsByTagName('meta');
    for (let i = 0; i < elem.children.length; i++) {
        let prop = elem.children[i].attributes.property.value,
            content = elem.children[i].attributes.content.value;
        for (let j = 0; j < headerItems.length; j++) {
            if (typeof(headerItems[j].attributes.property) !== "undefined" &&
                    headerItems[j].attributes.property.value === prop) {
                headerItems[j].attributes.content.value = content;
            }
        }
    }
}

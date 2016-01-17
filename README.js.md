Required reading
------------

* [ES6 features](https://github.com/lukehoban/es6features)
* [Promises](www.html5rocks.com/en/tutorials/es6/promises/)
* [WHATWG Fetch](https://jakearchibald.com/2015/thats-so-fetch/)
* [Immutable.js](https://facebook.github.io/immutable-js/), for the stuff in `/records`
* [JSDoc](http://usejsdoc.org/), proper documenting isn't about adding comments to make bad code readable.
* [React docs](https://facebook.github.io/react/docs/getting-started.html)
    - Quickstart
    - Guides (Yes, all of them)
    - Reference
        - Top-level API
        - Component API
        - Component specs & lifecycle
        - Tags & Attrs
        - Event system
* [Redux docs](http://rackt.org/redux/docs/introduction/index.html), yes all of it.
    - For actions we use [FSA](https://github.com/acdlite/flux-standard-action)
    - For API calls [redux-api-middleware](https://github.com/agraboso/redux-api-middleware)
* [FormatJS](http://formatjs.io/react/) For internationalisation


Run this before every commit
------------

```
npm run doc
npm run lint
```


Good reference
------------

* [ES6 features](https://github.com/lukehoban/es6features)
* [Google JS style guide](https://google.github.io/styleguide/javascriptguide.xml)
    Whenever in doubt, the google JS style guide provides a good fallback.
    - [Types](https://google.github.io/styleguide/javascriptguide.xml?showone=JavaScript_Types#JavaScript_Types) Useful for documenting function type declarations.

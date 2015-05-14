
 Argu.m = {
     init: function () {
         "use strict";
         $(document).on('pjax:success', Argu.m.setupSelectize);
         this.setupSelectize();
     },

     setupSelectize: function () {
         "use strict";

         $('.tag-list').selectize({
             delimiter: ',',
             valueField: 'name',
             labelField: 'name',
             searchField: 'name',
             persist: false,
             create: function(input) {
                 return {
                     name: input,
                     text: input
                 }
             },
             render: {
                 option: function(item, escape) {
                     return '<div><span><span>' + escape(item.name) + '</span><span>' + '(' +item.count + ')' + '</span></div>';
                 }
             },
             load: function(query, callback) {
                 if (!query.length) return callback();
                 $.ajax({
                     url: 't.json',
                     type: 'GET',
                     dataType: 'json',
                     data: {
                         q: query
                     },
                     error: function () {
                         callback();
                     },
                     success: function (res) {
                         callback(res.tags);
                     }
                 });
             }
         });
     }
 };
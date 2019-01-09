(function(){
    var factory = function (exports) {
      if(window.locale == 'ru')
      {
        exports.defaults.lang = markdown_ru_locale(exports);
      }
      else{
        exports.defaults.lang = markdown_en_locale(exports);
      }
    };

	// CommonJS/Node.js
	if (typeof require === "function" && typeof exports === "object" && typeof module === "object")
    {
        module.exports = factory;
    }
	else if (typeof define === "function")  // AMD/CMD/Sea.js
    {
		if (define.amd) { // for Require.js

			define(["editormd"], function(editormd) {
                factory(editormd);
            });

		} else { // for Sea.js
			define(function(require) {
                var editormd = require("../editormd");
                factory(editormd);
            });
		}
	}
	else
	{
        factory(window.editormd);
	}
  $(function() {
    $('.edit-markdown').each(function(){
     var height = $(this).attr('height') || 700;
     var pandaoId = 'edit-markdown-' +  this.id;
     $(this).wrap(`<div id=${pandaoId}> </div>`);
     var editor = editormd({
         id: pandaoId,
         path : "/lib/",
         height: height
     });
    });
  });

})();

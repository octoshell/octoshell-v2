
/**
 * jquery-markdown 1.0
 * @author Can Geliş
 * @license License file must be attached with the source code (MIT License)
 */
$.fn.insertAtCaret = function(text){
/**
 * @author Scott Klarr Jr
 * @url http://web.archive.org/web/20110102112946/http://www.scottklarr.com/topic/425/how-to-insert-text-into-a-textarea-where-the-cursor-is/
 */
    var txtarea = document.getElementById(this[0].id);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );

    if (br == "ie") {
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        strPos = range.text.length;
    } else if (br == "ff") strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0,strPos);
    var back = (txtarea.value).substring(strPos,txtarea.value.length);

    txtarea.value=front+text+back; strPos = strPos + text.length;

    if (br == "ie") {
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        range.moveStart ('character', strPos);
        range.moveEnd ('character', 0);
        range.select();
    } else if (br == "ff") {
        txtarea.selectionStart = strPos;
        txtarea.selectionEnd = strPos;
        txtarea.focus();
    }

    txtarea.scrollTop = scrollPos; 
}

$.fn.textReplace = function(options) {
    var settings = $.extend({
        selected: function() {
            return "";
        },
        no_selection: function() {
            return "";
        }
    }, options);
    var textarea = this, actual = this.get(0);
    var selectionStart = actual.selectionStart, selectionEnd = actual.selectionEnd;
    var text_to_replace = $(textarea).val().substring(selectionStart, selectionEnd);
    if (selectionStart === selectionEnd) {
        $(this).insertAtCaret(settings.no_selection());
    } else {
        value = $(textarea).val().substring(0, selectionStart) +
                settings.selected(text_to_replace) +
                $(textarea).val().substring(selectionEnd);
        $(textarea).val(value);
    }
    $(textarea).trigger('input');
}
String.prototype.repeat = function(num)
{
    return new Array(num + 1).join(this);
};
$.fn.mdBold = function(options) {
    var settings = $.extend({
        default: "Text Here"
    }, options);
    $(this).textReplace({
        selected: function(text) {
            return "**" + text + "**";
        },
        no_selection: function() {
            return "**" + settings.default + "**";
        }
    });
};
$.fn.mdItalic = function(options) {
    var settings = $.extend({
        default: "Text Here"
    }, options);
    $(this).textReplace({
        selected: function(text) {
            return "*" + text + "*";
        },
        no_selection: function() {
            return "*" + settings.default + "*";
        }
    });
};
$.fn.mdHeader = function(options) {
    var settings = $.extend({
        default: "Heading Here",
        number: 1
    }, options);
    $(this).textReplace({
        selected: function(text) {
            return '\n' + "#".repeat(settings.number) + " " + text + '\n\n';
        },
        no_selection: function() {
            return '\n' + "#".repeat(settings.number) + " " + settings.default + '\n\n';
        }
    });
};
$.fn.mdLink = function(options) {
    var settings = $.extend({
        default_text: "Link Text Here",
        default_url: "URL Here"
    }, options);
    $(this).textReplace({
        selected: function(text) {
            return '[' + text + '](' + settings.default_url + ')';
        },
        no_selection: function() {
            return '[' + settings.default_text + '](' + settings.default_url + ')';
        }
    });
};
$.fn.mdImage = function(options) {
    var settings = $.extend({
        default_alt_text: "",
        default_image_url: "Image URL Here",
        default_image_title: ""
    }, options);
    $(this).textReplace({
        selected: function(image_link) {
            return '![' + settings.default_alt_text + '](' + image_link + ' "' + settings.default_image_title + '")';
        },
        no_selection: function() {
            return '![' + settings.default_alt_text + '](' + settings.default_image_url + ' "' + settings.default_image_title + '")';
        }
    });
};
$.fn.mdCode = function(options) {
    var settings = $.extend({
        default: "Code here"
    }, options);
    $(this).textReplace({
        selected: function(code) {
            lines = code.split('\n');
            if (lines.length === 1) {
                return '`' + code + '`';
            } else {
                final_code = "";
                for (i = 0; i < lines.length; i++) {
                    final_code += "    " + lines[i] + '\n';
                }
                return final_code;
            }
        },
        no_selection: function() {
            return '`' + settings.default + '`';
        }
    });
    $(this).focus();
};
$.fn.mdQuote = function(options) {
    var settings = $.extend({
        default: "Quote here"
    }, options);
    $(this).textReplace({
        selected: function(code) {
            lines = code.split('\n');
            if (lines.length === 1) {
                return '\n> ' + code + '\n';
            } else {
                final_code = "\n";
                for (i = 0; i < lines.length; i++) {
                    final_code += "> " + lines[i] + '\n';
                }
                return final_code;
            }
        },
        no_selection: function() {
            return '\n> ' + settings.default + '\n';
        }
    });
}
$.fn.mdNumberedList = function(options) {
    var settings = $.extend({
        default: "List item"
    }, options);
    $(this).textReplace({
        selected: function(code) {
            lines = code.split('\n');
            if (lines.length === 1) {
                return '1. ' + code + '\n';
            } else {
                final_code = "\n";
                for (i = 0; i < lines.length; i++) {
                    final_code += (i+1)+". " + lines[i] + '\n';
                }
                return final_code;
            }
        },
        no_selection: function() {
            return '1. ' + settings.default + '\n';
        }
    });
}
$.fn.mdBulletList = function(options) {
    var settings = $.extend({
        default: "List item"
    }, options);
    $(this).textReplace({
        selected: function(code) {
            lines = code.split('\n');
            if (lines.length === 1) {
                return '- ' + code + '\n';
            } else {
                final_code = "\n";
                for (i = 0; i < lines.length; i++) {
                    final_code += "- " + lines[i] + '\n';
                }
                return final_code;
            }
        },
        no_selection: function() {
            return '- ' + settings.default + '\n';
        }
    });
};

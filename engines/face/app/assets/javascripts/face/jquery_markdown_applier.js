function add_markdown_toolbar(){
  function jqmdedit_do(e,a,f,args){
    e.stopPropagation();
    e.preventDefault();
    a[f](args);
  }
  $("textarea.markdown-edit").each(function(i) {
    var cl='js-edit-'+i;
    var classes = $(this).attr("class").split(' ');
    for(var j in classes){
      if(classes[j].startsWith('js-edit-')){
          return;
      }
    }
    $(this).addClass(cl);
    $(this).wrap('<div></div>');
    $(this).before("<div id=\"mde-but-"+i+"\" class=\"markdown-edit-buttons\"><a href='#' id=\"js-md-c"+
      i+"\" title=\"Code\"><i class=\"fas fa-edit\"></i></a><a href='#' id=\"js-md-b"+
      i+"\" title=\"Bold\"><i class=\"fas fa-bold\"></i></a><a href='#' id=\"js-md-i"+
      i+"\" title=\"Italic\"><i class=\"fas fa-italic\"></i></a><a href='#' id=\"js-md-l"+
      i+"\" title=\"Numbered list\"><i class=\"fas fa-list-ol\"></i></a><a href='#' id=\"js-md-u"+
      i+"\" title=\"Bullet list\"><i class=\"fas fa-list\"></i></a><a href='#' id=\"js-md-k"+
      i+"\" title=\"Hyperlink\"><i class=\"fas fa-link\"></i></a><a href='#' id=\"js-md-m"+
      i+"\" title=\"Image\"><i class=\"fas fa-camera\"></i></a><a href='#' id=\"js-md-q"+
      i+"\" title=\"Quoted text\"><i class=\"fas fa-quote-left\"></i></a><a href='#' id=\"js-md-h"+
      i+"\" title=\"Header\">H3</a><a href='#' id=\"js-md-H"+
      i+"\" title=\"Small header\">H4</a></div>");
    $('#js-md-c'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdCode');});
    $('#js-md-b'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdBold');});
    $('#js-md-i'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdItalic');});
    $('#js-md-l'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdNumberedList');});
    $('#js-md-u'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdBulletList');});
    $('#js-md-k'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdLink',{default_url: prompt('Enter URL please')});});
    $('#js-md-m'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdImage',{default_image_url: prompt('Enter URL Please')});});
    $('#js-md-h'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdHeader',{number: 3});});
    $('#js-md-H'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdHeader',{number: 4});});
    $('#js-md-q'+i).click(function(e){jqmdedit_do(e,$('.'+cl),'mdQuote');});
  });
}
$(function(){
  add_markdown_toolbar();
});

var myMarked = window.marked;
var marked_render = new myMarked.Renderer();
function marked_video(title, text, style){
  var list = title.split(';');
  var result='<video controls';
  if(style!=''){
    result = result+style
  }
  result = result+'>'
  list.forEach(function(item) {
    var elems = item.split('=');
    result = result+'<source src="'+elems[1]+'" type="'+elems[0]+'">';
  });
  return result+text+'</video>';
}
marked_render.image = function (href, title, text) {
  var style='';
  var m = text.match(/\{.*\}/);
  var ms = String(m);
  if(ms!='' && ms!='null'){
    style = ' style="'+ms.slice(1,-1)+'"'
    text=text.replace(/\{.*\}/,'')
  }
  if(href=='video'){
    return marked_video(title, text, style);
  }
  var ret=''
  ret=ret+'<img src="'+href+'"'+style
  if(title!=null){
    ret=ret+' alt="'+title+'"';
  }
  var st = String(text);
  if(st!=''){
    ret=ret+' title="'+text+'"';
  }
  ret=ret+'/>';
  return ret;
};

function apply_markdown(){
  $('.marked-preview').each(function(e){
    var src = $('#'+$(this).attr('data-myid'));
    $(this).html(marked($(src).val(),{renderer: marked_render}));
  });
  $('.markdown-edit').each(function(){
    $(this).on('input', function(e){
      clearTimeout($(this).last_update);
      var src = $(this);
      $(this).last_update = setTimeout(function() {
        var marked_text = marked(src.val(),{renderer: marked_render, gfm: true, smartLists: true});
        $('.marked-preview[data-myid="'+src.attr('id')+'"]').html(marked_text);
      }, 500);
    })
  })
}

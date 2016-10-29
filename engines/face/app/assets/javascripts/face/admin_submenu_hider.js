$(document).ready(function(){
  var menu = $('ul.submenu')
  var drop = $('ul.dropdown-menu', menu)
  var prev = null
  var dropped = false

  $('li[class!="dropdown"]', menu).each(function(i, e){
    var li = $(e)
    if (!dropped && prev && (prev.position().left > li.position().left)) {
      dropped = true
      $('li.dropdown', menu).show()
      prev.appendTo(drop)
    }
    if (dropped) {
      li.appendTo(drop)
    }
    prev = li
  })
})

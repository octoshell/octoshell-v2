function change_child_grouped_select(parent_string, child_string){
  var parent_selector = $(parent_string);
  var child_selector = $(child_string);
  var areas = child_selector.html();
  parent_selector.change(function() {
    var selected_elements =  $(parent_string + ' :selected');
    if(selected_elements.length)
      child_selector.empty();
    else
      child_selector.html(areas);

    var selected_areas = selected_elements.map(function(i,e){
      var escaped_area = $(e).text().replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
      var options = $(areas).filter("optgroup[label='" + escaped_area + "']").wrap('<p/>').parent().html();
      if (options) {
        child_selector.append(options);
      }
    });
  });
 parent_selector.trigger('change');
}

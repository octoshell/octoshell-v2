$(document).ready(function(){
  $("input#check-all-box").on("click", function(e){
    var boxes = $("input#selected_project_ids_");
    var original_box = this;
    boxes.each(function(i, e){
      e.checked = original_box.checked;
    });
  });
});

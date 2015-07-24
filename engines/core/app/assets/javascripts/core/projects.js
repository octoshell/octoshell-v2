$().ready(function(){
  $("#member_adder").bind("click", function(){
    $("tr#new_member_row").toggleClass("hidden");
    return false;
  })

  $(".project_access_toggle").each(function() {
    return $(this).on("click", function() {
      return $.ajax({
        url: $(this).attr("url"),
        type: "PUT"
      });
    });
});
})

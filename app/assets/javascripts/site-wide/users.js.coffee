$ ->
  $(".admin_toggle").each ->
    $(this).on "click", ->
      $.ajax
        url: $(this).attr("url")
        data:
          admin: @checked
        type: "PUT"

$ ->
  $("#empty-fields-opener").on "click", ->
    $link = $(@)
    $link.parents("table:first").find("tr.hidden").removeClass("hidden")
    $link.parents("tr:first").remove()
    false

  $(".raw-text-opener").on "click", (e) ->
    $(@).prev(".raw-ticket-message, .raw-reply").show()
    $(@).remove()
    false

  $("#ticket_subscribers_form, #ticket_tags_form").submit ->
    values = $(@).serialize()
    $.ajax(
      url: $(@).attr("url")
      data: values
      dataType: "JSON"
      type: "PUT"
    )

    false

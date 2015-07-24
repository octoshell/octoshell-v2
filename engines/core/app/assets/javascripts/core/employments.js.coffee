$ ->
  $("#new_department_adder").on("click", ->
    $("#employment_organization_department_name").attr("type", "text")
    $("#new_department_adder").hide()

    false
  )

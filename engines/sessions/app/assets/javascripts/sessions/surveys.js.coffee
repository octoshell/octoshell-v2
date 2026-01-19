$ ->
  $("div[data-max-values]").on "change :checkbox", ->
    max = Number($(@).data("max-values"))
    return if max <= 0
    condition = $(':checked', @).length >= max
    $(":not(:checked)", @).prop "disabled", condition
  $("div[data-max-values]").each (i, e) ->
    $(":checkbox:first", e).trigger("change")

  $("table.summable").each (i, table) ->
    table = $(table)
    row = $("tr:last", table).clone()
    row.find("th").html("Всего")

    table.recalc = ->
      row.find("td").each (j, td) ->
        td = $(td)
        val = 0
        $("tr", table).each (k, tr) ->
          v = Number $("td:eq(" + j + ")", $(tr)).find("input").val()
          val += v unless _(v).isNaN()
        td.html(val)

    table.on "blur input", =>
      table.recalc()

    table.recalc()
    table.append(row)

  $(".submit-survey").on "click", ->
    $button = $(@)
    $form = $button.parents("form:first")
    $form.prop "action", $button.data("action")
    true

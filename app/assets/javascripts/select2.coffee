$ ->
  $('@instance-search').on 'change', ->
    input = $(@)
    document.location = input.data('url').replace('%s', input.val())

  $("form@autosubmit :hidden[role!='instance-search']").on 'change', ->
    $(@).parents('form:first').submit()

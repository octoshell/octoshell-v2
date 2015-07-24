$(function(){
  select2_localization = {
    ru: "Выберите значение",
    en: "Choose"
  }

  $('select, select2-container, input.chosen, select.chosen').each(function(i, e){
    var select = $(e)
    var options = select.find('option')
    if (options.size() == 1) {
      $(options[0]).select()
    }
    options = {
      placeholder: select2_localization[window.locale],
      allowClear: true
    }

    if (select.hasClass('ajax')) {
      options.ajax = {
        url: select.data('source'),
        dataType: 'json',
        quietMillis: 100,
        data: function(term, page) {
          return {
            q: $.trim(term),
            page: page,
            per: 10
          }
        },
        results: function(data, page) {
          var more = (page * 10) < data.total
          return { results: data.records, more: more }
        }
      }
    }
    select.select2(options)
  })
});

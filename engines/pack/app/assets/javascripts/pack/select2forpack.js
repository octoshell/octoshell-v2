  function  apply_select2(){
  
  select2_localization = {
    ru: "Выберите значение",
    en: "Choose"
  }

  $('select, select2-container, select2-ajax, input.chosen, select.chosen').each(function(i, e){
    var select = $(e)
    var options = select.find('option')
    if (options.size() == 1) {
      $(options[0]).select()
    }
    options = {
      placeholder: select2_localization[window.locale],
      allowClear: true
    }

    if (select.hasClass('ajax') || select.hasClass('select2-ajax')) {
       select.removeClass('ajax select2-ajax');
       for ( i in options )
       {
         console.log(options[i]);
       }
      options.ajax = {
        url: select.data('source'),
        dataType: 'json',
        quietMillis: 100,
        data: function(params) {
          return {
            q: $.trim(params.term),
            page: params.page,
            per: 10
          }
        },
        processResults: function(data, page) {
          var more = (page * 10) < data.total
          return { results: data.records, pagination:{more: more }}
        },
      }
    }
    select.select2(options)
  })
}

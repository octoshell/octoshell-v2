$(function(){
  select2_localization = {
    ru: "Выберите значение",
    en: "Choose"
  }

  $('select, select2-container, select2-ajax, input.chosen, select.chosen').not('.select2-custom').each(function(i, e){
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
        processResults: function(data, params) {
          var page = params.page | 1;
          var more = (page * 10) < data.total;
          return { results: data.records, pagination:{more: more }}
        },
      }
    }
    select.select2(options)
  });
  $(document).on( "select2:select", "[redirect-url]", function(e) {
   var id = e.params.data.id;
   var url = $(this).attr('redirect-url');
   window.location.href = url.replace('{{id}}',id);
  });
});

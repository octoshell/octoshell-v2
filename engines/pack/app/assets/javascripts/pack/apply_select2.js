function apply_select2(url,aim='select, select2-container, select2-ajax, input.chosen, select.chosen')

{

	$(function(){
  
  select2_localization = {
    ru: "Выберите значение",
    en: "Choose"
  }

  
  
  $(aim).each(function(i, e){
    var select = $(e)
    var source;
  if (url)
  {
    source=url;
  }
  else
  {
    source=select.data('source');
  }
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
        url: source,
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
});
};




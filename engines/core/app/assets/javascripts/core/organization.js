function remove_extra_spaces(){
  $(document).on('change',"textarea, input[type='text']",function(e){
    var current_val =  $(this).val();
    current_val = current_val.replace(/(\s){2,}/g,' ')
                             .replace(/^\s/g,'')
                             .replace(/\s$/g,'');
    $(this).val(current_val);
  });
}

function getJSONSync(url,success)
{
  $.ajax({
  dataType: "json",
  url: url,
  success: success,
  async: false
});
}

function apply_select(){
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
  })
};


function apply_select_to(elem,path,extra_params = {})
{
  var select = elem
  var options = select.find('option')
  if (options.size() == 1) {
    $(options[0]).select()
  }
  if(typeof select2_localization !== 'undefined'){
    var placeholder = select2_localization[window.locale];
  }
  else {
    var placeholder = 'Введите значение';
  }
  options = {
    placeholder: placeholder,
    allowClear: true
  }

    options.ajax = {
      url: path,
      dataType: 'json',
      quietMillis: 100,
      data: function(params) {
        var init =  {
                      q: $.trim(params.term),
                      page: params.page,
                      per: 10
                    }
        for (var attrname in extra_params) { init[attrname] = extra_params[attrname]; }
        return init;
      },
      processResults: function(data, params) {
        var page = params.page | 1;
        var more = (page * 10) < data.total;
        return { results: data.records, pagination:{more: more }}
      },
    }
  select.select2(options);
}

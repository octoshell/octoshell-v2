// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require_directory .
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require autocomplete-rails
$(function(){
	
 $(".stale_error").not(":checked").prevAll("div.form-group").find("input,select").prop("disabled",true);
});

$(document).on('change',".stale_error",function(){
	var obj= $(this).prevAll("div.form-group").find("input,select");
	if  ( $(this).is(':checked') )

		obj.prop('disabled',false);
	else
		obj.prop('disabled',true);

});

 $(document).on('focus',".my_datepicker", function(){
    $(this).datepicker({
  dateFormat: 'mm-dd-yy',
  minDate: new Date(),
  
});
});

function bind_func_disable (enable,disable,item)
{

	function disable_enable_select()
	{
	
		if  ( $(enable).prop("checked") )
		{
			$(item).prop("disabled",false);	
			return;
		}
	

		if  ( $(disable).prop("checked") )
		{
			$(item).prop("disabled",true);	
		}	

	};	

	disable_enable_select();
	$(enable).change(disable_enable_select);
	$(disable).change(disable_enable_select);

};

$(function ()
{

  $(`form.ajax-form`).submit(function(event) {
  
    
    
    var msg   = $(this).serialize();
        $.ajax({
          type: 'GET',
          dataType: 'script',
          url: $(this).attr('action'),

          data: msg
         
          
          
        });
 
    
    return false;

  });
});

function render_on_click(source,html,target)
{
  


}

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






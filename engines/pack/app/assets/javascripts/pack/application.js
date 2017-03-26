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

function enab_radio( enab,paste )
{

	function enab_paste()
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
	$(enable1).change(disable_enable_select);
	$(enable2).change(disable_enable_select);

};



